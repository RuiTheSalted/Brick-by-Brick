extends Control

# WHEN CLICKED EXIT THE GAME
func _on_yes_button_pressed() -> void:
	get_tree().quit()

# WHEN CLICKED HIDE THE EXIT SCREEN
func _on_no_button_pressed() -> void:
	hide() 
