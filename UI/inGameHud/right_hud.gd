extends Control

@onready var inGameSettings = $InGameSettings

func _on_settings_button_pressed() -> void:
	inGameSettings.show()
	get_tree().paused = true
#checkout brick_spawner and freeze/unfreeze
#fiddle with the upgrades button when able to
