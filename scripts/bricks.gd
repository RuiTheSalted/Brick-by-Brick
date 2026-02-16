extends Node2D

var hits = 0
# Textures for bricks health after each hit
var brick_textures = [
	"res://assets/spritesArt/menuArtOutGame/Green Brick.png",
	"res://assets/spritesArt/menuArtOutGame/Orange Brick.png",
]

var health = 1	# Default brick health
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bricks")	# Add brick to group for easy detection
	
func hit() -> void:
	hits += 1
	health -= 1
	print("Brick hit ", hits, "times.", "Brick has ", health, "health")

	if health <= 0:
		queue_free()		# Destroy brick after health = 0
	else:
		health -= 1
		var texture_index = min(hits, brick_textures.size() - 1)
		var new_texture = load(brick_textures[texture_index])
		if new_texture:
			Sprite2D.texture = new_texture
		# Decision: visual feeback change brick color 
		modulate = Color(1, 0.5, 0.5) 
