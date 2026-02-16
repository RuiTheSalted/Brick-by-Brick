extends Node2D

var ball: CharacterBody2D
var ball_scene = preload("res://scenes/ball.tscn")
var nballs = 0 # Default starting with 1 ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the ball node in the scene
	ball = get_tree().get_first_node_in_group("ball")	
	
func _on_button_pressed() -> void:
	print("Button pressed! Spawning ", nballs, " ball(s) ...")
	
	# Spawn nballs per upgrade click
	var new_ball = ball_scene.instantiate()
		
	# Each new_ball spawns in random position
	var random_x = randf_range(50, 1230)
	var random_y = randf_range(50, 300)
	new_ball.position = Vector2(random_x, random_y)
		
	# Add the ball to the scene
	get_parent().add_child(new_ball)
		
	# Increment nballs per click for next upgrade
	nballs += 1
