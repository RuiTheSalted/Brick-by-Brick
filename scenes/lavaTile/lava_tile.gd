extends Area2D

@export var damage_per_tick: int = 5
@export var tick_rate: float = 0.5
@export var lifetime: float = 8.0

var tick_timer: float = 0.0

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
		return

	tick_timer += delta
	if tick_timer >= tick_rate:
		tick_timer = 0.0
		for brick in get_tree().get_nodes_in_group("bricks"):
			if not is_instance_valid(brick):
				continue
			if global_position.distance_to(brick.global_position) <= 64:
				if brick.has_method("take_damage"):
					brick.take_damage(damage_per_tick)
