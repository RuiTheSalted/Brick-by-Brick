# res://maps/specialMaps/spiralLevel/scripts/tennis_court.gd
# Draws and animates a mini pong/tennis court at the center of the spiral level
# Acts as the "heart" - the thing players are protecting from incoming bricks
# Paddles move independently with reaction delays to create realistic diagonal play
# When ball escapes it emits a signal so spiral_level.gd can spawn a real projectile
# Ball has a spawn delay on start and after every reset so it doesn't instantly appear
extends Node2D

# Signal emitted when ball escapes court
# position = world position of escape, direction = normalized travel direction
signal ball_escaped(position: Vector2, direction: Vector2)

# Court dimensions in pixels
const COURT_W := 180.0
const COURT_H := 120.0
const BALL_RADIUS := 4.0
const PADDLE_W := 6.0
const PADDLE_H := 22.0
const BALL_SPEED := 100.0

# Chance the ball escapes when a paddle misses (0.0 to 1.0)
# 0.25 = 25% chance - fun without being overpowered
const ESCAPE_CHANCE := 0.25

# Minimum vertical fraction enforced on every paddle hit
# Prevents ball from getting stuck bouncing purely horizontally
const MIN_VERTICAL_FRACTION := 0.3

# Delay before ball appears after spawning or reset
# Gives a brief pause so ball doesnt instantly appear
const BALL_SPAWN_DELAY := 1.2

# Court colors
const COLOR_COURT := Color(0.13, 0.54, 0.13, 1.0)   # Green court surface
const COLOR_LINE := Color(1.0, 1.0, 1.0, 0.85)       # White court lines
const COLOR_BALL := Color(0.85, 1.0, 0.2, 1.0)       # Yellow tennis ball
const COLOR_PADDLE := Color(1.0, 1.0, 1.0, 0.95)     # White paddles
const COLOR_NET := Color(1.0, 1.0, 1.0, 0.5)         # Semi-transparent net
const COLOR_BG := Color(0.08, 0.08, 0.08, 1.0)       # Dark background behind court

# Ball state - position is relative to court center (0,0)
var ball_pos := Vector2.ZERO
var ball_vel := Vector2(BALL_SPEED, BALL_SPEED * 0.7)

# Tracks whether ball is currently in spawn delay
# During delay ball is hidden and does not move
var ball_spawning: bool = true
var spawn_timer: float = 0.0

# Left paddle - slower with longer reaction delay, misses more often
var left_paddle_y := 0.0
var left_paddle_target := 0.0
var left_paddle_speed := 55.0
var left_reaction_timer := 0.0
var left_reaction_delay := 0.15  # Seconds before left paddle updates its target

# Right paddle - faster with shorter reaction delay, more accurate
var right_paddle_y := 0.0
var right_paddle_target := 0.0
var right_paddle_speed := 65.0
var right_reaction_timer := 0.0
var right_reaction_delay := 0.10  # Seconds before right paddle updates its target

func _ready() -> void:
	ball_pos = Vector2.ZERO
	ball_spawning = true
	spawn_timer = 0.0
	# Set random diagonal direction ready for when delay ends
	# Angle between 25-65 degrees prevents purely horizontal starts
	var start_angle = randf_range(0.4, 1.1)
	var dir_x = 1.0 if randf() > 0.5 else -1.0
	ball_vel = Vector2(dir_x * cos(start_angle), sin(start_angle)) * BALL_SPEED
	# Randomly flip vertical for variety
	if randf() > 0.5:
		ball_vel.y *= -1.0

func _process(delta: float) -> void:
	# Handle spawn delay - ball stays hidden and still until timer expires
	if ball_spawning:
		spawn_timer += delta
		if spawn_timer >= BALL_SPAWN_DELAY:
			# Delay over - ball becomes active and starts moving
			ball_spawning = false
			spawn_timer = 0.0
		# Paddles still animate during delay so court doesnt look frozen
		_update_paddle_targets(delta)
		_move_paddles(delta)
		queue_redraw()
		return

	# Normal gameplay - update everything
	_update_paddle_targets(delta)
	_move_paddles(delta)
	_move_ball(delta)
	queue_redraw()

func _update_paddle_targets(delta: float) -> void:
	# Left paddle reaction - only updates target after delay
	# Creates realistic lag that makes paddles feel natural and independent
	left_reaction_timer += delta
	if left_reaction_timer >= left_reaction_delay:
		left_reaction_timer = 0.0
		if ball_vel.x < 0:
			# Ball moving toward left paddle - track it
			left_paddle_target = ball_pos.y
		else:
			# Ball moving away - drift slowly back toward center
			left_paddle_target = left_paddle_target * 0.95

	# Right paddle reaction - independent timer and target from left
	right_reaction_timer += delta
	if right_reaction_timer >= right_reaction_delay:
		right_reaction_timer = 0.0
		if ball_vel.x > 0:
			# Ball moving toward right paddle - track it
			right_paddle_target = ball_pos.y
		else:
			# Ball moving away - drift slowly back toward center
			right_paddle_target = right_paddle_target * 0.95

func _move_paddles(delta: float) -> void:
	var half_h: float = COURT_H / 2.0 - PADDLE_H / 2.0

	# Each paddle moves toward its own independent target at its own speed
	# This makes them look and behave differently from each other
	left_paddle_y = move_toward(left_paddle_y, left_paddle_target, left_paddle_speed * delta)
	right_paddle_y = move_toward(right_paddle_y, right_paddle_target, right_paddle_speed * delta)

	# Clamp so paddles stay inside court bounds
	left_paddle_y = clamp(left_paddle_y, -half_h, half_h)
	right_paddle_y = clamp(right_paddle_y, -half_h, half_h)

func _move_ball(delta: float) -> void:
	ball_pos += ball_vel * delta

	var half_h = COURT_H / 2.0 - BALL_RADIUS
	var half_w = COURT_W / 2.0 - BALL_RADIUS - PADDLE_W

	# Bounce off top and bottom walls
	if ball_pos.y > half_h or ball_pos.y < -half_h:
		ball_vel.y *= -1.0
		ball_pos.y = clamp(ball_pos.y, -half_h, half_h)
		# Add slight random angle variation on wall bounce
		# Prevents predictable repeating bounce patterns
		ball_vel.x += randf_range(-8.0, 8.0)
		ball_vel = ball_vel.normalized() * BALL_SPEED

	# Left paddle collision
	if ball_pos.x < -half_w:
		var paddle_top = left_paddle_y - PADDLE_H / 2.0
		var paddle_bot = left_paddle_y + PADDLE_H / 2.0
		if ball_pos.y >= paddle_top and ball_pos.y <= paddle_bot:
			ball_vel.x = abs(ball_vel.x)
			# Hit offset: center hit = shallow angle, edge hit = steep angle
			var hit_offset = (ball_pos.y - left_paddle_y) / (PADDLE_H / 2.0)
			ball_vel.y = clamp(hit_offset * BALL_SPEED * 1.2, -BALL_SPEED * 0.9, BALL_SPEED * 0.9)
			# Enforce minimum vertical component so ball always leaves at a diagonal
			# Prevents purely horizontal bouncing which freezes paddle movement
			if abs(ball_vel.y) < BALL_SPEED * MIN_VERTICAL_FRACTION:
				ball_vel.y = BALL_SPEED * MIN_VERTICAL_FRACTION * sign(randf_range(-1.0, 1.0))
			ball_vel = ball_vel.normalized() * BALL_SPEED
		else:
			# Paddle missed - check for escape
			_handle_miss(Vector2(-1, ball_vel.normalized().y))

	# Right paddle collision
	if ball_pos.x > half_w:
		var paddle_top = right_paddle_y - PADDLE_H / 2.0
		var paddle_bot = right_paddle_y + PADDLE_H / 2.0
		if ball_pos.y >= paddle_top and ball_pos.y <= paddle_bot:
			ball_vel.x = -abs(ball_vel.x)
			var hit_offset = (ball_pos.y - right_paddle_y) / (PADDLE_H / 2.0)
			ball_vel.y = clamp(hit_offset * BALL_SPEED * 1.2, -BALL_SPEED * 0.9, BALL_SPEED * 0.9)
			# Enforce minimum vertical component
			if abs(ball_vel.y) < BALL_SPEED * MIN_VERTICAL_FRACTION:
				ball_vel.y = BALL_SPEED * MIN_VERTICAL_FRACTION * sign(randf_range(-1.0, 1.0))
			ball_vel = ball_vel.normalized() * BALL_SPEED
		else:
			# Paddle missed - check for escape
			_handle_miss(Vector2(1, ball_vel.normalized().y))

func _handle_miss(base_direction: Vector2) -> void:
	# Roll for escape chance
	if randf() < ESCAPE_CHANCE:
		# Use actual ball direction so escaped ball flies out naturally
		# Add slight random vertical variation for unpredictability
		var escape_dir = Vector2(
			base_direction.x,
			base_direction.y + randf_range(-0.3, 0.3)
		).normalized()
		# Spawn point offset outside court boundary so ball clears court immediately
		# +20 pushes spawn point well beyond court edge
		var edge_offset = Vector2(base_direction.x * (COURT_W / 2.0 + 20.0), ball_pos.y)
		var world_pos = global_position + edge_offset
		ball_escaped.emit(world_pos, escape_dir)

	# Always reset ball after miss
	_reset_ball()

func _reset_ball() -> void:
	ball_pos = Vector2.ZERO
	# Trigger spawn delay again so ball doesnt instantly reappear after miss
	ball_spawning = true
	spawn_timer = 0.0
	# Set random diagonal direction ready for when delay ends
	var angle = randf_range(0.4, 1.1)
	var dir_x = 1.0 if randf() > 0.5 else -1.0
	ball_vel = Vector2(dir_x * cos(angle), sin(angle)) * BALL_SPEED
	# Randomly flip vertical direction for variety
	if randf() > 0.5:
		ball_vel.y *= -1.0

func _draw() -> void:
	var half_w = COURT_W / 2.0
	var half_h = COURT_H / 2.0

	# Dark background so court stands out against gray level background
	draw_rect(Rect2(-half_w - 6, -half_h - 6, COURT_W + 12, COURT_H + 12), COLOR_BG)

	# Court background green surface
	draw_rect(Rect2(-half_w, -half_h, COURT_W, COURT_H), COLOR_COURT)

	# Court border
	draw_rect(Rect2(-half_w, -half_h, COURT_W, COURT_H), COLOR_LINE, false, 1.5)

	# Center service line
	draw_line(Vector2(0, -half_h), Vector2(0, half_h), COLOR_LINE, 0.8)

	# Horizontal mid court line
	draw_line(Vector2(-half_w, 0), Vector2(half_w, 0), COLOR_LINE, 0.8)

	# Dashed net at center
	var y: float = -half_h
	var net_dash := 4.0
	while y < half_h:
		draw_line(Vector2(0, y), Vector2(0, min(y + net_dash, half_h)), COLOR_NET, 2.0)
		y += net_dash * 2.0

	# Left paddle
	draw_rect(
		Rect2(-half_w + 2.0, left_paddle_y - PADDLE_H / 2.0, PADDLE_W, PADDLE_H),
		COLOR_PADDLE
	)

	# Right paddle
	draw_rect(
		Rect2(half_w - 2.0 - PADDLE_W, right_paddle_y - PADDLE_H / 2.0, PADDLE_W, PADDLE_H),
		COLOR_PADDLE
	)

	# Only draw ball when not in spawn delay
	# During delay court and paddles still show but ball is hidden
	if not ball_spawning:
		draw_circle(ball_pos, BALL_RADIUS, COLOR_BALL)
