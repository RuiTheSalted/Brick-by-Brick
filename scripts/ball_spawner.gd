extends Node2D

var ball: CharacterBody2D
var ball_scene = preload("res://scenes/ball.tscn")
var nballs = 1 # Default starting with 1 ball

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Find the ball node in the scene
	ball = get_tree().get_first_node_in_group("ball")	
	
func _on_button_pressed() -> void:
	print("Spawning ", nballs, " ball(s) ...")
	
	# Spawn nballs per upgrade click
	var new_ball = ball_scene.instantiate()
		
	# Each new_ball spawns in random position
	var random_x = randf_range(200, 1000)
	var random_y = randf_range(400,500)
	new_ball.position = Vector2(random_x, random_y)
		
	# Add the ball to the scene
	get_parent().add_child(new_ball)
	
	# Add to group so button can find new ball
	new_ball.add_to_group("ball")
	
	# Match upgrade level of existing balls
	var existing_ball = get_tree().get_first_node_in_group("ball")
	if existing_ball and existing_ball != new_ball:
		var target_level = existing_ball.upgrade_level	
		for i in range(target_level):
			new_ball.upgrade()
			
	# Increment nballs per click for next upgrade
	nballs += 1
