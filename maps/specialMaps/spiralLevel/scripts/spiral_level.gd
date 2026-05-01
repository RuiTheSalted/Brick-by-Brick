# res://maps/specialMaps/spiralLevel/scripts/spiral_level.gd
# Main level script - generates the spiral path at runtime and positions the tennis court
# Also handles escaped court balls - spawns real projectiles that can hit bricks
extends Node2D

# Spiral settings - tweak these in Inspector to change spiral shape
@export var spiral_turns: float = 3.0           # How many times the spiral wraps inward
@export var spiral_points: int = 300            # Smoothness of the path (higher = smoother)
@export var spiral_start_radius: float = 290.0  # Outside edge radius
@export var spiral_end_radius: float = 70.0     # How close to center the spiral ends

# Toggle in Inspector - true = rectangular box spiral, false = regular circular spiral
@export var use_box_spiral: bool = true

# Damage the escaped court ball deals to bricks it hits
const ESCAPE_BALL_DAMAGE := 2

# Speed of the escaped court ball projectile after leaving the court
const ESCAPE_BALL_SPEED := 400.0

# Tennis ball sprite used for the escaped projectile
# Change this path to swap the escaped ball appearance
const TENNIS_BALL_SPRITE := "res://assets/spritesArt/ball/tennisBall.png"

# Escaped ball size matches BALL_RADIUS * 2 from tennis_court.gd
# Update this if BALL_RADIUS changes in tennis_court.gd
const ESCAPE_BALL_DIAMETER := 8.0

@onready var spiral_path: Path2D = $SpiralPath
@onready var tennis_court: Node2D = $TennisCourt

# Center of the 890x720 game viewport inside levelWithUI
# Left UI is 180px wide, right UI is 210px wide
# Game area: 1280 - 180 - 210 = 890px wide, 720px tall
const GAME_CENTER := Vector2(445, 355)

func _ready() -> void:
	# Reset game state so HP and round start fresh
	GameStats.reset_for_new_level()
	# Generate the spiral path FIRST before spawner tries to use it
	_generate_spiral_path()
	# Place tennis court at exact center of game area
	tennis_court.position = GAME_CENTER
	# Connect to court ball escape signal so we can spawn a real projectile
	tennis_court.ball_escaped.connect(_on_court_ball_escaped)
	# Play level music
	AudioManager.play_music(SoundBank.MUSIC_LEVEL_FOREST_1)

	# Wait one frame to ensure path is fully in the scene tree before spawner uses it
	await get_tree().process_frame

	# Then manually start the spawner after path is guaranteed to exist
	$Spawner.start_spawner()

func _on_court_ball_escaped(spawn_pos: Vector2, direction: Vector2) -> void:
	# Spawn a real projectile that travels across the screen and can hit bricks
	var escaped_ball = RigidBody2D.new()
	escaped_ball.gravity_scale = 0.0  # No gravity - travels in a straight line
	escaped_ball.collision_layer = 0
	escaped_ball.collision_mask = 0

	# Add sprite using tennis ball texture
	var sprite = Sprite2D.new()
	var texture = load(TENNIS_BALL_SPRITE)
	if texture:
		sprite.texture = texture
		# Scale sprite to exactly match the court ball visual size
		# ESCAPE_BALL_DIAMETER matches BALL_RADIUS * 2 in tennis_court.gd
		var texture_size = float(texture.get_width())
		var scale_factor = ESCAPE_BALL_DIAMETER / texture_size
		sprite.scale = Vector2(scale_factor, scale_factor)
	escaped_ball.add_child(sprite)

	# Add collision shape sized to match the visual ball size
	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	# Radius is half of diameter to match BALL_RADIUS in tennis_court.gd
	shape.radius = ESCAPE_BALL_DIAMETER / 2.0
	col.shape = shape
	escaped_ball.add_child(col)

	# Position the ball at the escape point (already offset outside court)
	escaped_ball.position = spawn_pos
	# Set velocity in escape direction at escape speed
	escaped_ball.linear_velocity = direction * ESCAPE_BALL_SPEED

	# Enable contact monitoring so body_entered signal fires on brick collision
	escaped_ball.contact_monitor = true
	escaped_ball.max_contacts_reported = 4

	# Add to scene before connecting signals
	add_child(escaped_ball)

	# Connect collision handler - destroys ball and damages brick on hit
	escaped_ball.body_entered.connect(
		func(body):
			_on_escaped_ball_hit(body, escaped_ball)
	)

	# Auto destroy after 3 seconds if it hits nothing and travels off screen
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(escaped_ball):
		escaped_ball.queue_free()

func _on_escaped_ball_hit(body: Node, escaped_ball: RigidBody2D) -> void:
	# Check if the body is a brick or has a brick parent
	var brick = body if body.is_in_group("bricks") else body.get_parent()
	if brick and brick.is_in_group("bricks"):
		# Deal damage to the brick
		brick.take_damage(ESCAPE_BALL_DAMAGE)
		# Play tennis ball bounce sound
		AudioManager.play_ball_sfx("Tennis Ball")
		# Destroy escaped ball after hitting a brick
		if is_instance_valid(escaped_ball):
			escaped_ball.queue_free()

func _generate_spiral_path() -> void:
	var curve = Curve2D.new()

	for i in range(spiral_points + 1):
		var t = float(i) / float(spiral_points)
		# Angle increases as t goes from 0 to 1, creating the spiral rotation
		# TAU * 0.65 offsets the start point to the top right of the spiral
		# matching the intended design where bricks emerge from the top right edge
		var angle = (t * spiral_turns * TAU) + (TAU * 0.65)
		# Radius shrinks linearly from outside edge to center
		var radius = lerp(spiral_start_radius, spiral_end_radius, t)
		var point: Vector2

		if use_box_spiral:
			# Rectangular superellipse - wider than tall to fit 890x720 viewport
			# power controls corner roundness: 4.0 = balanced rounded corners
			var power := 4.0
			# width_factor fills horizontal space, height_factor fits vertical space
			# Tuned to match 890x720 game area aspect ratio
			var width_factor := 1.45
			var height_factor := 0.85
			var cos_a = cos(angle)
			var sin_a = sin(angle)
			# sign() preserves direction, pow() with 2/power creates smooth corners
			var x = radius * width_factor * sign(cos_a) * pow(abs(cos_a), 2.0 / power)
			var y = radius * height_factor * sign(sin_a) * pow(abs(sin_a), 2.0 / power)
			point = GAME_CENTER + Vector2(x, y)
		else:
			# Regular circular spiral
			# Convert polar coordinates to cartesian and offset to game center
			point = GAME_CENTER + Vector2(cos(angle), sin(angle)) * radius

		curve.add_point(point)

	spiral_path.curve = curve
