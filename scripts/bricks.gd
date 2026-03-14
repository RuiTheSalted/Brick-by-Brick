extends Node2D

@export var health = 10 # Total Brick health
@export var speed := 100
@export var brick_type : BrickType = BrickType.Normal

enum BrickType {
	Normal,
	Lava
}

# Global hit counter:
var hits = 0
# Guard to prevent lose_life from firing multiple times before queue_free takes effect
var _reached_end: bool = false

# Textures for bricks health after each hit
# Color progression per hit: healthy -> damaged -> critical health
var brick_textures = [
	"res://assets/spritesArt/bricks/Green Brick.png",
	"res://assets/spritesArt/bricks/Orange Brick.png",
	"res://assets/spritesArt/bricks/Red Brick.png",
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bricks")	# Add brick to group for easy detection
	_update_visuals()
	_update_label()
	
func take_damage(amount: int, body = null) -> void:
			
	health -= amount
	hits += 1
	# print("Brick hit ", hits, " time(s). Health remaining: ", health)

	# Award points on every hit
	if get_tree().root.has_node("ScoreManager"):
		get_tree().root.get_node("ScoreManager").add_score(10)

	if health <= 0:
		if get_tree().root.has_node("ScoreManager"):
			get_tree().root.get_node("ScoreManager").add_score(
				get_tree().root.get_node("ScoreManager").score_per_brick
			)
		queue_free()
	else:
		_update_visuals()
		_update_label()
		
func _update_visuals() -> void:
		if brick_type == BrickType.Lava:
			$Sprite2D.texture = load("res://assets/spritesArt/bricks/Lava Brick.png")
			return
			
		# Update texture based on hit count
		if has_node("HealthLabel"):
			$HealthLabel.text = str(health)
		if not has_node("Sprite2D"):
			return
			
		var max_health = 10
		var thirds = max_health / 3.0
		
		if health > thirds * 2.0:
			#print("Healthy")
			$Sprite2D.texture = load(brick_textures[0])
		elif health > thirds:
			#print("Injured")
			$Sprite2D.texture = load(brick_textures[1])
		else:
			#print("Critical")
			$Sprite2D.texture = load(brick_textures[2])
			
func _update_label()-> void:
	if has_node("HealthLabel"):
		$HealthLabel.text = str(health)

func _physics_process(delta):
	var path_follow = get_parent()
	path_follow.progress += speed * delta

	if not _reached_end and path_follow.progress_ratio >= 1.0:
		_reached_end = true
		var gm = get_node_or_null("GameManager")
		if gm:
			gm.lose_life(1)
		else:
			push_error("bricks.gd: GameManager autoload not found at GameManager")
		path_follow.queue_free()

func is_lava():
	return brick_type == BrickType.Lava
