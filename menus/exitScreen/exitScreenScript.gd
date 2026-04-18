extends Control

func _on_yes_button_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().quit()

func _on_no_button_pressed() -> void:
	AudioManager.play_ui_click()
	hide()
