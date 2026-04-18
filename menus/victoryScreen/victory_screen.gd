extends Control

func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_sfx(SoundBank.WIN_SCREEN)

func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")
# make freeplay button work
