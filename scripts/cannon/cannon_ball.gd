extends CharacterBody2D

# --- Textures (assign one per 5 total upgrades in the Inspector) ---
@export var ball_textures: Array[Texture2D] = [
	preload("res://assets/spritesArt/ball/ball.png"),        # tier 0  (0–4 total upgrades)
	preload("res://assets/spritesArt/ball/tennisBall.png"),  # tier 1  (5–9)
	preload("res://assets/spritesArt/ball/BeachBall.png"),   # tier 2  (10–14)
	preload("res://assets/spritesArt/ball/iceball.png"),     # tier 3  (15–19)
	preload("res://assets/spritesArt/ball/Cannon_Ball.png"), # tier 4  (20+)
]

# --- Runtime Stats (set by UpgradeManager on spawn) ---
var damage: int = 1
var ball_speed: float = 800.0
var max_bounces: int = 10

# --- Currency per hit ---
@export var currency_per_hit: int = 10

# --- Internal State ---
var bounce_count: int = 0
var _movement: Vector2 = Vector2.ZERO
var _base_display_size: Vector2 = Vector2.ZERO

# --- Signal ---
signal ball_died


func _ready() -> void:
	add_to_group("cannonballs")
	set_physics_process(false)
	# Record the original display size before any texture swap
	var sprite = get_node_or_null("cannonBall")
	if sprite and sprite.texture:
		_base_display_size = sprite.texture.get_size() * sprite.scale
	if get_tree().root.has_node("UpgradeManager"):
		get_tree().root.get_node("UpgradeManager").apply_to_ball(self)


# Called by cannon to start movement
func shoot(directional_force: Vector2, _gravity: float) -> void:
	_movement = directional_force.normalized() * ball_speed
	set_physics_process(true)


# Called by UpgradeManager to swap texture based on total upgrade tier
func apply_texture_tier(tier: int) -> void:
	if ball_textures.size() > 0:
		var idx = min(tier / 5, ball_textures.size() - 1)
		var sprite = get_node_or_null("cannonBall")
		if sprite:
			sprite.texture = ball_textures[idx]
			# Rescale to preserve the original display size regardless of new texture dimensions
			if _base_display_size != Vector2.ZERO and sprite.texture:
				sprite.scale = _base_display_size / sprite.texture.get_size()


func _physics_process(_delta: float) -> void:
	velocity = _movement.normalized() * ball_speed
	move_and_slide()

	if get_slide_collision_count() > 0:
		var collision = get_slide_collision(0)
		var hit = collision.get_collider()
		var normal = collision.get_normal()

		if hit.is_in_group("bricks"):
			hit.take_damage(damage)
			if get_tree().root.has_node("CurrencyManager"):
				get_tree().root.get_node("CurrencyManager").add_currency(currency_per_hit)

		elif hit.has_method("take_damage"):
			hit.take_damage(damage)
			if get_tree().root.has_node("CurrencyManager"):
				get_tree().root.get_node("CurrencyManager").add_currency(currency_per_hit)

		_movement = _movement.bounce(normal)
		bounce_count += 1

		if bounce_count >= max_bounces:
			emit_signal("ball_died")
			queue_free()


# Off screen — die
func _on_visibility_notifier_exit_screen() -> void:
	emit_signal("ball_died")
	queue_free()
