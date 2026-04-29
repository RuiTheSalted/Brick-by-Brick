# res://maps/specialMaps/spiralLevel/scripts/tennis_court.gd
# Draws and animates a mini pong/tennis court at the center of the spiral level
# Acts as the "heart" - the thing players are protecting from incoming bricks
# Purely decorative for now - future: damage court when bricks reach center
extends Node2D

# Court dimensions in pixels
const COURT_W := 120.0
const COURT_H := 80.0
const BALL_RADIUS := 4.0
const PADDLE_W := 6.0
const PADDLE_H := 22.0
const BALL_SPEED := 100.0

# Court colors
const COLOR_COURT := Color(0.13, 0.54, 0.13, 1.0)   # Green court surface
const COLOR_LINE := Color(1.0, 1.0, 1.0, 0.85)       # White court lines
const COLOR_BALL := Color(0.85, 1.0, 0.2, 1.0)       # Yellow tennis ball
const COLOR_PADDLE := Color(1.0, 1.0, 1.0, 0.95)     # White paddles
const COLOR_NET := Color(1.0, 1.0, 1.0, 0.5)         # Semi-transparent net
const COLOR_BG := Color(0.08, 0.08, 0.08, 1.0)       # Dark background behind court

# Ball state - position is relative to court center (0,0)
var ball_pos := Vector2.ZERO
var ball_vel := Vector2(BALL_SPEED, BALL_SPEED * 0.6)

# Paddle Y positions - auto controlled to chase the ball
var left_paddle_y := 0.0
var right_paddle_y := 0.0
var paddle_speed := 70.0

func _ready() -> void:
	ball_pos = Vector2.ZERO

func _process(delta: float) -> void:
	_move_ball(delta)
	_move_paddles(delta)
	# Trigger redraw every frame for animation
	queue_redraw()

func _move_ball(delta: float) -> void:
	ball_pos += ball_vel * delta

	var half_h = COURT_H / 2.0 - BALL_RADIUS
	var half_w = COURT_W / 2.0 - BALL_RADIUS - PADDLE_W

	# Bounce off top and bottom walls
	if ball_pos.y > half_h or ball_pos.y < -half_h:
		ball_vel.y *= -1.0
		ball_pos.y = clamp(ball_pos.y, -half_h, half_h)

	# Left paddle collision
	if ball_pos.x < -half_w:
		var paddle_top = left_paddle_y - PADDLE_H / 2.0
		var paddle_bot = left_paddle_y + PADDLE_H / 2.0
		if ball_pos.y >= paddle_top and ball_pos.y <= paddle_bot:
			ball_vel.x = abs(ball_vel.x)
			# Angle the ball based on where it hits the paddle
			var hit_offset = (ball_pos.y - left_paddle_y) / (PADDLE_H / 2.0)
			ball_vel.y = hit_offset * BALL_SPEED
		else:
			# Paddle missed - reset ball to center
			ball_pos = Vector2.ZERO
			ball_vel.x = abs(ball_vel.x)

	# Right paddle collision
	if ball_pos.x > half_w:
		var paddle_top = right_paddle_y - PADDLE_H / 2.0
		var paddle_bot = right_paddle_y + PADDLE_H / 2.0
		if ball_pos.y >= paddle_top and ball_pos.y <= paddle_bot:
			ball_vel.x = -abs(ball_vel.x)
			var hit_offset = (ball_pos.y - right_paddle_y) / (PADDLE_H / 2.0)
			ball_vel.y = hit_offset * BALL_SPEED
		else:
			# Paddle missed - reset ball to center
			ball_pos = Vector2.ZERO
			ball_vel.x = -abs(ball_vel.x)

func _move_paddles(delta: float) -> void:
	# Auto-play: both paddles chase the ball automatically
	var chase_speed: float = paddle_speed * delta
	var half_h: float = COURT_H / 2.0 - PADDLE_H / 2.0

	# Left paddle tracks ball
	left_paddle_y = move_toward(left_paddle_y, ball_pos.y, chase_speed * 1.8)
	right_paddle_y = move_toward(right_paddle_y, ball_pos.y, chase_speed * 1.8)

	# Clamp paddles so they don't go outside court bounds
	left_paddle_y = clamp(left_paddle_y, -half_h, half_h)
	right_paddle_y = clamp(right_paddle_y, -half_h, half_h)

func _draw() -> void:
	var half_w = COURT_W / 2.0
	var half_h = COURT_H / 2.0

	# Dark background so court stands out against gray level background
	draw_rect(Rect2(-half_w - 6, -half_h - 6, COURT_W + 12, COURT_H + 12), COLOR_BG)

	# Draw court background (green surface)
	draw_rect(Rect2(-half_w, -half_h, COURT_W, COURT_H), COLOR_COURT)

	# Draw court border
	draw_rect(Rect2(-half_w, -half_h, COURT_W, COURT_H), COLOR_LINE, false, 1.5)

	# Draw center service line
	draw_line(Vector2(0, -half_h), Vector2(0, half_h), COLOR_LINE, 0.8)

	# Draw horizontal mid court line
	draw_line(Vector2(-half_w, 0), Vector2(half_w, 0), COLOR_LINE, 0.8)

	# Draw dashed net at center
	var y: float = -half_h
	var net_dash := 4.0
	while y < half_h:
		draw_line(Vector2(0, y), Vector2(0, min(y + net_dash, half_h)), COLOR_NET, 2.0)
		y += net_dash * 2.0

	# Draw left paddle
	draw_rect(
		Rect2(-half_w + 2.0, left_paddle_y - PADDLE_H / 2.0, PADDLE_W, PADDLE_H),
		COLOR_PADDLE
	)

	# Draw right paddle
	draw_rect(
		Rect2(half_w - 2.0 - PADDLE_W, right_paddle_y - PADDLE_H / 2.0, PADDLE_W, PADDLE_H),
		COLOR_PADDLE
	)

	# Draw the tennis ball
	draw_circle(ball_pos, BALL_RADIUS, COLOR_BALL)
