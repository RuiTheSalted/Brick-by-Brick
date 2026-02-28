extends CharacterBody2D

# --- Base Stats (set these as your starting values) ---
@export var base_damage: int = 25
@export var base_speed: float = 800.0
@export var base_max_bounces: int = 10
@export var currency_per_hit: int = 10

# --- Textures (add one texture per 5 levels, e.g. 5 textures for levels 0-4, 5-9, 10-14...) ---
@export var ball_textures: Array[Texture2D] = []

# --- Runtime Stats (scaled by upgrade level) ---
var damage: int = 25
var ball_speed: float = 800.0
var max_bounces: int = 10

# --- Internal State ---
var bounce_count: int = 0
var _movement: Vector2 = Vector2.ZERO

# --- Signal ---
signal ball_died


func _ready() -> void:
	# Apply current upgrade level from CurrencyManager on spawn
	if get_tree().root.has_node("CurrencyManager"):
		var cm = get_tree().root.get_node("CurrencyManager")
		set_upgrade_level(cm.upgrade_level)


# Called by cannon to start movement
func shoot(directional_force: Vector2, _gravity: float) -> void:
	# Gravity ignored — straight line like Idle Breakout
	_movement = directional_force.normalized() * ball_speed
	set_physics_process(true)


# Apply upgrade level — scales all stats and swaps texture
func set_upgrade_level(level: int) -> void:
	# Damage: +5 per level
	damage = base_damage + (level * 5)

	# Speed: exponential scaling (1.05 ^ level * base)
	ball_speed = base_speed * pow(1.05, level)

	# Bounces: +2 per level
	max_bounces = base_max_bounces + (level * 2)

	# Texture: swap every 5 levels
	if ball_textures.size() > 0:
		var texture_index = min(level / 5, ball_textures.size() - 1)
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.texture = ball_textures[texture_index]

	print("Ball: Upgrade level ", level, " applied | DMG:", damage, " SPD:", snappedf(ball_speed, 0.1), " Bounces:", max_bounces)


func _physics_process(_delta: float) -> void:
	velocity = _movement
	move_and_slide()

	# Only handle first collision to avoid corner-scrambling
	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var hit = collision.get_collider()
		var normal = collision.get_normal()

		# Deal damage and award currency if enemy
		if hit.has_method("take_damage"):
			hit.take_damage(damage)
			# Award currency
			if get_tree().root.has_node("CurrencyManager"):
				get_tree().root.get_node("CurrencyManager").add_currency(currency_per_hit)

		# Bounce
		_movement = _movement.bounce(normal)

		# Track bounces
		bounce_count += 1
		print("Ball: Bounce ", bounce_count, "/", max_bounces)

		if bounce_count >= max_bounces:
			print("Ball: Max bounces reached, dying")
			emit_signal("ball_died")
			queue_free()


# Off screen — die
func _on_visibility_notifier_exit_screen() -> void:
	print("Ball: Left screen, dying")
	emit_signal("ball_died")
	queue_free()
