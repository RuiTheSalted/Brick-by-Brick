extends Control

func _on_okay_button_pressed() -> void:
	AudioManager.play_ui_click()
	hide()
