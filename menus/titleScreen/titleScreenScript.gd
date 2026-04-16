extends Control

#SCREENS VARIABLES
@onready var exitScreen = $exitConfirm
@onready var settingsScreen = $settingsPopUp
@onready var helpScreen = $HelpScreen

func _ready():
	_apply_hover_to_all_buttons(self)

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

func add_hover_effect(btn: BaseButton):
	btn.mouse_entered.connect(func():
		btn.modulate = Color(1.2, 1.2, 1.2, 1)
	)
	btn.mouse_exited.connect(func():
		btn.modulate = Color(1, 1, 1, 1)
	)

func _apply_hover_to_all_buttons(node):
	for child in node.get_children():
		if child is BaseButton:
			add_hover_effect(child)
		_apply_hover_to_all_buttons(child)
