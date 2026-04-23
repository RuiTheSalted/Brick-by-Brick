extends Control

func _on_exit_button_pressed() -> void:
	AudioManager.play_ui_click(2)
	hide()
