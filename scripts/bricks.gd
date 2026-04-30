extends Node2D

@export var health: int = 10 # Total Brick health
@export var speed: float = 100
@export var brick_type : BrickType = BrickType.Normal

signal died

enum BrickType {
	Normal,
	Lava,
	Unbreakable
}

# Guard to prevent lose_life from firing multiple times before queue_free takes effect
var _reached_end: bool = false

# Color progression per hit: healthy -> damaged -> critical health
var brickTextures = [
	preload("res://assets/spritesArt/bricks/Red Brick.png"),
	preload("res://assets/spritesArt/bricks/Orange Brick.png"),
	preload("res://assets/spritesArt/bricks/Yellow Brick.png"),
	preload("res://assets/spritesArt/bricks/Green Brick.png"),
	preload("res://assets/spritesArt/bricks/Blue Brick.png"),
	preload("res://assets/spritesArt/bricks/Purple Brick.png"),
]

var lavaBrickTexture = preload("res://assets/spritesArt/bricks/Lava Brick.png")
# Strong brick: purple when full, red when half health stripped

var unbreakableBrickTexture = preload("res://assets/spritesArt/bricks/Metal Brick.png")

var is_slowed: bool = false
var slow_timer: float = 0.0
var slow_duration: float = 2.0 #ICEBALL SLOW DURATION
var slow_multiplier: float = 0.5 #SLOWS BRICKS TO HALF SPEED

var is_weakened: bool = false
var weak_timer: float = 0.0
var weak_duration: float = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bricks")	# Add brick to group for easy detection
	_update_visuals()
	_update_label()


func take_damage(amount: int) -> void:
	if brick_type == BrickType.Unbreakable:
		return
	var stats = get_tree().get_first_node_in_group("gamestats")
	if is_slowed:
		if stats and stats.ammo_data[stats.ammo_name].get("frozenDamageBonus", false):
			amount *= 2
	if is_weakened:
		amount *= 2

	health -= amount
	
	# Plays break sound if dying, damage sound if surviviing
	if health <= 0:
		AudioManager.play_sfx(SoundBank.BRICK_BREAK)
	else:
		AudioManager.play_sfx(SoundBank.BRICK_DAMAGE, true)
	
	if stats:
		var cash_multiplier = stats.ammo_data[stats.ammo_name].get("diamondAffinity", 1)
		var base_currency = amount * cash_multiplier
		if brick_type == BrickType.Lava:
			stats.add_currency(base_currency * 2)
		else:
			stats.add_currency(base_currency)
	else:
		push_error("Gamestats not found in group 'gamestats'")

	if health <= 0:
		died.emit()
		get_parent().queue_free()
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
		

	# Normal: color progression in thirds
	var index := 0 
	
	if health <= 3:
		index = 0 #Red
	elif health <= 6:
		index = 1 #Orange
	elif health <= 9:
		index = 2 #Yellow
	elif health <= 12: 
		index = 3 #Green
	elif health <= 15:
		index = 4 #Blue
	else: 
		index = 5 #Purple
	
	$Sprite2D.texture = brickTextures[index]


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

	if is_weakened:
		weak_timer -= delta
		if weak_timer <= 0:
			is_weakened = false
	
	if is_slowed and is_weakened:
		$Sprite2D.modulate = Color(0.7, 0.5, 1.0)  # purple-blue mix
	elif is_slowed:
		$Sprite2D.modulate = Color(0.6, 0.8, 1.0)  # blue
	elif is_weakened:
		$Sprite2D.modulate = Color(0.8, 0.4, 1.0)  # purple
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
		died.emit()
		path_follow.queue_free()


func is_lava():
	return brick_type == BrickType.Lava


func apply_slow(duration: float = -1.0, strength: float = -1.0):
	if brick_type == BrickType.Unbreakable:
		return
	is_slowed = true
	if duration < 0:
		slow_timer = INF
	else:
		# Only replace timer if new duration is longer
		slow_timer = max(slow_timer, duration)
	if strength >= 0:
		slow_multiplier = clamp(1.0 - (strength * 0.1), 0.05, 1.0)
	else:
		slow_multiplier = 0.5


func apply_weakness() -> void:
	if brick_type == BrickType.Unbreakable:
		return
	is_weakened = true
	weak_timer = weak_duration
