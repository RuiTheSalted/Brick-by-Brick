extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 900.0
var damage: int = 1
var max_distance: float = 400.0
var traveled: float = 0.0

func _physics_process(delta: float) -> void:
	var movement = direction * speed * delta
	position += movement
	traveled += movement.length()

	if traveled >= max_distance:
		queue_free()
		return

	for body in get_overlapping_bodies():
		if body.is_in_group("bricks"):
			body.take_damage(damage)
			queue_free()
			return
		var parent = body.get_parent()
		if parent and parent.is_in_group("bricks"):
			parent.take_damage(damage)
			queue_free()
			return
