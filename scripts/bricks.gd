extends Node2D

@export var health: int = 10 # Total Brick health
@export var speed: float = 100
@export var brick_type : BrickType = BrickType.Normal

enum BrickType {
	Normal,
	Lava,
	Strong,
	Unbreakable
}

# Guard to prevent lose_life from firing multiple times before queue_free takes effect
var _reached_end: bool = false

# Color progression per hit: healthy -> damaged -> critical health
var brickTextures = [
	preload("res://assets/spritesArt/bricks/Green Brick.png"),
	preload("res://assets/spritesArt/bricks/Orange Brick.png"),
	preload("res://assets/spritesArt/bricks/Red Brick.png"),
]

var lavaBrickTexture = preload("res://assets/spritesArt/bricks/Lava Brick.png")
# Strong brick: purple when full, red when half health stripped
var strongBrickTextures = [
	preload("res://assets/spritesArt/bricks/Purple Brick.png"),
	preload("res://assets/spritesArt/bricks/Red Brick.png"),
]
var unbreakableBrickTexture = preload("res://assets/spritesArt/bricks/Metal Brick.png")

var is_slowed: bool = false
var slow_timer: float = 0.0
var slow_duration: float = 2.0 #ICEBALL SLOW DURATION
var slow_multiplier: float = 0.5 #SLOWS BRICKS TO HALF SPEED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bricks")	# Add brick to group for easy detection
	if brick_type == BrickType.Strong:
		health = 20
	_update_visuals()
	_update_label()
	
func take_damage(amount: int) -> void:
	if brick_type == BrickType.Unbreakable:
		return
	health -= amount
	
	# Plays break sound if dying, damage sound if surviviing
	if health <= 0:
		AudioManager.play_sfx(SoundBank.BRICK_BREAK)
	else:
		AudioManager.play_sfx(SoundBank.BRICK_DAMAGE, true)
	
	var stats = get_tree().get_first_node_in_group("gamestats")
	if stats:
		if brick_type == BrickType.Lava:
			stats.add_currency(amount * 2)
		else:
			stats.add_currency(amount)
	else:
		push_error("Gamestats not found in group 'gamestats'")

	if health <= 0:
		queue_free()
	else:
		_update_visuals()
		_update_label()

func _update_visuals() -> void:
	if not has_node("Sprite2D"):
		return

	match brick_type:
		BrickType.Lava:
			$Sprite2D.texture = lavaBrickTexture
			return
		BrickType.Unbreakable:
			$Sprite2D.texture = unbreakableBrickTexture
			return
		BrickType.Strong:
			# Changes appearance once first 10 HP are stripped
			if health > 10:
				$Sprite2D.texture = strongBrickTextures[0]
			else:
				$Sprite2D.texture = strongBrickTextures[1]
			return

	# Normal: color progression in thirds
	var thirds = 10.0 / 3.0
	if health > thirds * 2.0:
		$Sprite2D.texture = brickTextures[0]
	elif health > thirds:
		$Sprite2D.texture = brickTextures[1]
	else:
		$Sprite2D.texture = brickTextures[2]


func _update_label() -> void:
	if has_node("HealthLabel"):
		if brick_type == BrickType.Unbreakable:
			$HealthLabel.text = ""
		else:
			$HealthLabel.text = str(health)

func _physics_process(delta):
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			is_slowed = false

	if is_slowed:
		$Sprite2D.modulate = Color(0.6, 0.8, 1.0)
	else:
		$Sprite2D.modulate = Color(1, 1, 1)

	var path_follow = get_parent()
	# Only move/track end if placed on a path (not a static level brick)
	if not path_follow is PathFollow2D:
		return

	var current_speed = speed
	if is_slowed:
		current_speed *= slow_multiplier
	path_follow.progress += current_speed * delta

	# Detect reaching end of path & dying
	if not _reached_end and path_follow.progress_ratio >= 1.0:
		_reached_end = true
		if brick_type != BrickType.Unbreakable:
			var stats = get_tree().get_first_node_in_group("gamestats")
			if stats:
				stats.set_hp(stats.hp - health)
			else:
				push_error("GameStats not found in group 'gamestats'")
		path_follow.queue_free()

func is_lava():
	return brick_type == BrickType.Lava

func apply_slow():
	if brick_type == BrickType.Unbreakable:
		return
	is_slowed = true
	slow_timer = slow_duration
