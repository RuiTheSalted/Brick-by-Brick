extends Control

#SCREENS VARIABLES
@onready var exitScreen = $exitConfirm
@onready var settingsScreen = $settingsPopUp
@onready var helpScreen = $HelpScreen

# SHOW EXIT SCREEN
func _on_button_exit_pressed() -> void:
	exitScreen.show()

# SHOW SETTINGS
func _on_button_settings_pressed() -> void:
	settingsScreen.show()

# SHOW HELP SCREEN
func _on_button_help_pressed() -> void:
	helpScreen.show()

# SWITCH TO ACHIEVEMENTS SCREEN
func _on_button_achievements_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/achievementsScreen/achievementsScreen.tscn")

# SWITCH TO BALLS SHOWCASE SCREEN
func _on_balls_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/ballsScreen/ballsScreen.tscn")

# SWITCH TO MAP SELECTION SCREEN
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/playScreen/mapSelectionScreen.tscn")
