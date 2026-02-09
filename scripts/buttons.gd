extends Node2D

var ball: CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the ball node in the scene
	ball = get_tree().get_first_node_in_group("ball")
	
	if not ball:
		# Alternative: find ball by unique name in the level
		var level = get_tree().get_root().get_node("Level")
		if level:
			ball = level.get_node("Ball")
			
func _on_button_pressed() -> void:
	print("You are pressing button!")
	print("Button pressed! Upgrading ball ...")
	
	if ball and ball.has_method("upgrade"):
		ball.upgrade()
	else:
		print("Error: Ball not found or upgrade method missing")
