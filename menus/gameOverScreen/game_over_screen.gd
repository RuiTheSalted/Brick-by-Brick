extends Control

func _ready():
	AudioManager.stop_music()
	AudioManager.play_sfx(SoundBank.LOSE_SCREEN)

func _on_home_button_pressed(): 
	var stats = get_tree().get_first_node_in_group("gamestats")

	if stats:
		stats.reset_game()

	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")


func _on_restart_button_pressed():
	var stats = get_tree().get_first_node_in_group("gamestats")
	get_tree().paused = false
	stats.restart_game()
