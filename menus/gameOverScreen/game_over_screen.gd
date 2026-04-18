extends Control

func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx(SoundBank.LOSE_SCREEN)

func _on_home_button_pressed() -> void:
	print("Restart pressed")
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")
#make restart button work
