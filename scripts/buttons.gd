extends Node2D

func _on_button_pressed() -> void:
	print("Upgrading all balls! ")
	var balls = get_tree().get_nodes_in_group("ball")
	
	if balls.is_empty():
		print("Error: No balls found")
		return
	
	for ball in balls:
		if ball.has_method("upgrade"):
			ball.upgrade()
		else:
			print("Error: Ball not found or upgrade method missing")
