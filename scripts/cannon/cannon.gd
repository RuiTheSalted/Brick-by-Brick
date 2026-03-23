@tool
extends CharacterBody2D

# Cannon Settings
@export var cannon_velocity: float = 800.0
@export var cannon_gravity: float = 500.0
@export var cannon_delay: float = 0.25

# Ball limit
@export var max_balls: int = 50 #this is in cannon.tscn inspector
var current_balls: int = 0

# Cannon tip
@export var cannonBall_spawn: Node2D

# Sound + Animation
@export var cannon_sound: AudioStreamPlayer2D
@export var anim_player: AnimationPlayer

# Trajectory Preview
@export var preview_ingame: bool = false
@export var preview_line_length: int = 5
@export var preview_line_count: int = 30
@export var preview_line_color: Color = Color(1.0, 0.8, 0.2, 0.8)
@export var preview_bounce_color: Color = Color(1.0, 0.4, 0.2, 0.8)
@export var preview_max_bounces: int = 1

# Internal State
var waited: float = 0.0
var shooting: bool = false
var directional_force: Vector2 = Vector2.ZERO

# Cached trajectory points
var _trajectory_points: Array = []

# Cached node references
var _rotator: Node2D = null


func _ready():
	add_to_group("cannons")

	if not cannonBall_spawn:
		push_error("cannonBall_spawn Node2D is not assigned!")

	if has_node("Rotator"):
		_rotator = $Rotator

	update_directional_force()
	
	var stats = get_tree().get_first_node_in_group("gamestats")
	if stats:
		stats.ammo_type_changed.connect(_on_ammo_changed)
	apply_ammo_stats()

func _input(event):
	if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept"):
		shooting = true
	elif event.is_action_released("ui_select") or event.is_action_released("ui_accept"):
		shooting = false

func _process(delta):
	if _rotator and not Engine.is_editor_hint():
		var direction = get_global_mouse_position() - global_position
		direction.y = min(direction.y, 0.0)
		if direction == Vector2.ZERO:
			direction = Vector2.UP
		_rotator.rotation = direction.angle() + PI / 2

	update_directional_force()
	_update_trajectory()
	if Engine.is_editor_hint() or preview_ingame:
		queue_redraw()

		waited += delta
		if shooting and current_balls < max_balls:
			if waited >= cannon_delay:
				shoot()
				waited = 0.0

func update_directional_force():
	if cannonBall_spawn:
		var raw = get_global_mouse_position() - cannonBall_spawn.global_position
		if raw.length() < 10.0:
			return
		var direction = raw
		direction.y = min(direction.y, 0.0)
		if direction == Vector2.ZERO:
			direction = Vector2.UP
		directional_force = direction.normalized() * cannon_velocity
	else:
		directional_force = Vector2.ZERO

func _build_trajectory_no_raycast():
	var pos = cannonBall_spawn.global_position
	var vel = directional_force
	var grav = cannon_gravity
	var time_step = 1.0 / 60.0

	_trajectory_points.append({ "pos": pos, "bounce": false })

	for i in range(preview_line_count):
		var t = preview_line_length * time_step
		var next_pos = pos + Vector2(vel.x * t, vel.y * t + 0.5 * grav * t * t)
		vel = Vector2(vel.x, vel.y + grav * t)
		_trajectory_points.append({ "pos": next_pos, "bounce": false })
		pos = next_pos

func _update_trajectory():
	_trajectory_points.clear()

	if not cannonBall_spawn:
		return
	if not (Engine.is_editor_hint() or preview_ingame):
		return

	if Engine.is_editor_hint():
		_build_trajectory_no_raycast()
		return

	var space = get_world_2d().direct_space_state
	var time_step = 1.0 / 60.0
	var pos = cannonBall_spawn.global_position
	var vel = directional_force
	var grav = cannon_gravity
	var bounces = 0
	var after_bounce = false

	_trajectory_points.append({ "pos": pos, "bounce": false })

	var steps_remaining = preview_line_count
	while steps_remaining > 0:
		var t = preview_line_length * time_step
		var next_pos = pos + Vector2(vel.x * t, vel.y * t + 0.5 * grav * t * t)
		var next_vel = Vector2(vel.x, vel.y + grav * t)

		var query = PhysicsRayQueryParameters2D.create(pos, next_pos)
		query.exclude = [self]
		query.collision_mask = 0xFFFFFFFF
		var result = space.intersect_ray(query)

		if result:
			_trajectory_points.append({ "pos": result.position, "bounce": after_bounce })
			if bounces >= preview_max_bounces:
				break
			vel = next_vel.bounce(result.normal)
			pos = result.position + result.normal * 1.0
			bounces += 1
			after_bounce = true
		else:
			_trajectory_points.append({ "pos": next_pos, "bounce": after_bounce })
			pos = next_pos
			vel = next_vel
			steps_remaining -= 1

func _draw():
	if _trajectory_points.size() < 2:
		return
	for i in range(1, _trajectory_points.size()):
		var from = to_local(_trajectory_points[i - 1].pos)
		var to = to_local(_trajectory_points[i].pos)
		var color = preview_bounce_color if _trajectory_points[i].bounce else preview_line_color
		_draw_dashed_line(from, to, color, 2)

func _draw_dashed_line(from: Vector2, to: Vector2, color: Color, width: float):
	var dash_length: float = 8.0
	var gap_length: float = 6.0
	var total_length = from.distance_to(to)
	var direction = (to - from).normalized()
	var traveled = 0.0
	var drawing = true

	while traveled < total_length:
		var segment = dash_length if drawing else gap_length
		var end = min(traveled + segment, total_length)
		if drawing:
			draw_line(from + direction * traveled, from + direction * end, color, width)
		traveled = end
		drawing = not drawing

func shoot():
	var stats = get_tree().get_first_node_in_group("gamestats")

	if not stats or not stats.ammo_scene:
		push_warning("Cannot shoot: ammo_scene not found in GameStats!")
		return

	if not cannonBall_spawn:
		push_warning("Cannot shoot: cannonBall_spawn is not assigned!")
		return

	if cannon_sound:
		cannon_sound.pitch_scale = randf_range(0.95, 1.05)
		cannon_sound.play()

	if anim_player:
		anim_player.play("shake")
		
	var ammo_stats = stats.ammo_data[stats.ammo_name]
	var cannonBall = stats.ammo_scene.instantiate()
	
	cannonBall.damage = ammo_stats["damage"]
	cannonBall.max_bounces = ammo_stats["bounces"]
	cannonBall.ball_speed = ammo_stats["speed"]
	cannonBall.scale = Vector2(ammo_stats["size"], ammo_stats["size"])

	get_parent().add_child(cannonBall)
	cannonBall.global_position = cannonBall_spawn.global_position

	if cannonBall.has_method("shoot"):
		cannonBall.shoot(directional_force, cannon_gravity)
		current_balls += 1
		cannonBall.ball_died.connect(_on_ball_died)
	else:
		push_warning("Cannonball scene does not have a 'shoot' method!")

func _on_ball_died():
	current_balls -= 1

func apply_ammo_stats():
		var stats = get_tree().get_first_node_in_group("gamestats")
		if stats and stats.ammo_data.has(stats.ammo_name):
			cannon_delay = stats.ammo_data[stats.ammo_name]["shootSpeed"]
			print("cannon_delay set to: ", cannon_delay)

func _on_ammo_changed(_name, _icon):
	apply_ammo_stats()
	print("Cannon: Ball returned | Balls in play: ", current_balls, "/", max_balls)
