extends Control

@onready var inGameSettings = $InGameSettings

func _on_settings_button_pressed() -> void:
	inGameSettings.show()
