extends Control

signal confirmed

func _on_yes_button_pressed() -> void:
	AudioManager.play_ui_click()
	confirmed.emit()
	hide()   # closes popup


func _on_no_button_pressed() -> void:
	AudioManager.play_ui_click()
	hide()
