extends Node

signal lives_changed(new_lives)

@export var starting_lives :=1

var lives := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lives = starting_lives
	emit_signal("lives_changed", lives)

func lose_life(amount := 1):
	lives -= amount
	emit_signal("lives_changed", lives)
	
	if lives <= 0:
		game_over()

func game_over():
	print("GameOver")
	get_tree().paused = true
	get_tree().change_scene_to_file("res://menus/gameOverScreen/gameOverScreen.tscn")
