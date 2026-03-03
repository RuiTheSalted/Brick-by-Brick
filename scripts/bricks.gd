extends Node2D

@export var health = 10 # Total Brick health

# Global hit counter:
var hits = 0

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
	
func take_damage(amount: int) -> void:
	health -= amount
	hits += 1
	# print("Brick hit ", hits, " time(s). Health remaining: ", health)

	if health <= 0:
		queue_free()
	else:
		_update_visuals()
		_update_label()
		
func _update_visuals() -> void:
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
