# res://maps/specialMaps/spiralLevel/scripts/spiral_level.gd
# Main level script - generates the spiral path at runtime and positions the tennis court
extends Node2D

# Spiral settings - tweak these in Inspector to change spiral shape
@export var spiral_turns: float = 3.0           # How many times the spiral wraps inward
@export var spiral_points: int = 300            # Smoothness of the path (higher = smoother)
@export var spiral_start_radius: float = 260.0  # Outside edge radius
@export var spiral_end_radius: float = 80.0     # How close to center the spiral ends

# Toggle in Inspector - true = box spiral, false = regular circular spiral
@export var use_box_spiral: bool = true

@onready var spiral_path: Path2D = $SpiralPath
@onready var tennis_court: Node2D = $TennisCourt

# Center of the game area accounting for left UI (180px) and right UI (210px)
# Total width 1280 - 180 - 210 = 890 game area, center at 180 + 445 = 625
# Height center is simply 720 / 2 = 360
const GAME_CENTER := Vector2(660, 340)

func _ready() -> void:
	# Generate the spiral path FIRST before spawner tries to use it
	_generate_spiral_path()
	# Place tennis court at exact center of game area
	tennis_court.position = GAME_CENTER
	# Play level music
	AudioManager.play_music(SoundBank.MUSIC_LEVEL_FOREST_1)

	# Wait one frame to ensure path is fully in the scene tree before spawner uses it
	await get_tree().process_frame

	# Then manually start the spawner after path is guaranteed to exist
	$Spawner.start_spawner()

func _generate_spiral_path() -> void:
	var curve = Curve2D.new()

	for i in range(spiral_points + 1):
		var t = float(i) / float(spiral_points)
		# Angle increases as t goes from 0 to 1, creating the spiral rotation
		# TAU * 0.75 offsets the start point to the top of the spiral
		var angle = (t * spiral_turns * TAU) + (TAU * 0.75)
		# Radius shrinks linearly from outside edge to center
		var radius = lerp(spiral_start_radius, spiral_end_radius, t)
		var point: Vector2

		if use_box_spiral:
			# Superellipse formula creates a smooth rounded square shape
			# Power controls corner roundness:
			# 3.0 = softly rounded, 4.0 = balanced (recommended), 6.0 = tighter corners
			var power := 4.0
			var cos_a = cos(angle)
			var sin_a = sin(angle)
			# sign() preserves direction, pow() with 2/power creates the rounded corner curve
			var x = radius * sign(cos_a) * pow(abs(cos_a), 2.0 / power)
			var y = radius * sign(sin_a) * pow(abs(sin_a), 2.0 / power)
			point = GAME_CENTER + Vector2(x, y)
		else:
			# Regular circular spiral
			# Convert polar coordinates to cartesian and offset to game center
			point = GAME_CENTER + Vector2(cos(angle), sin(angle)) * radius

		curve.add_point(point)

	spiral_path.curve = curve
