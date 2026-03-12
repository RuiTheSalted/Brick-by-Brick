extends Control


func _on_home_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().paused = false
		hide()


#make restart button work
