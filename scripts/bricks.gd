extends Node2D

var hits = 0
var health = 10 # Total Brick health

# Textures for bricks health after each hit
var brick_textures = [
	"res://assets/spritesArt/bricks/Green Brick.png",
	"res://assets/spritesArt/bricks/Orange Brick.png",
	"res://assets/spritesArt/bricks/Red Brick.png",
]

#Color progression per hit: fresh -> damaged -> critical health
var hit_colors = [
	Color(1.0, 1.0, 1.0),
	Color(1.0, 0.85, 0.2),
	Color(1.0, 0.45, 0.1),
	Color(0.9, 0.1, 0.1),
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bricks")	# Add brick to group for easy detection
	_update_visuals()
	
func hit() -> void:
	hits += 1
	health -= 1
	print("Brick hit ", hits, " time(s).", " Health, remaining: ", health)

	if health <= 0:
		queue_free()		# Destroy brick after health = 0
	else:
		_update_visuals()
		
func _update_visuals() -> void:
		# Update texture based on hit count
		var texture_index = min(hits, brick_textures.size() - 1)
		var new_texture = load(brick_textures[texture_index])
		if new_texture and has_node("Sprite2D"):
			$Sprite2D.texture = new_texture
			# Apply color change regardless of texture
