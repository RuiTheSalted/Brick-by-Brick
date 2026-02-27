extends CharacterBody2D

# Explodes on impact
@export var explode_on_impact: bool = true

# Damage
@export var damage: int = 25

# Gravity
var _gravity: float = 0.0

# Movement
var _movement := Vector2()

# Bounce factor
var bounce: float = 0.6

# Whether physics processing is active
var _active: bool = false


# Initialize shot
func shoot(directional_force: Vector2, gravity: float) -> void:
	_movement = directional_force
	_gravity = gravity
	_active = true
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if not _active:
		return

	# Simulate gravity
	_movement.y += delta * _gravity

	# Move and detect collisions
	velocity = _movement
	var collision = move_and_collide(velocity * delta)

	if collision:
		# Deal damage to whatever was hit before exploding
		var hit = collision.get_collider()
		if hit.has_method("take_damage"):
			hit.take_damage(damage)

		if explode_on_impact:
			explode()
			return

		# Apply bounce physics using the collision normal
		var normal = collision.get_normal()
		_movement = _movement.reflect(normal) * bounce


# On screen exit
func _on_visibility_notifier_exit_screen() -> void:
	queue_free()


# On impact
func explode() -> void:
	queue_free()


# Return the damage this ball deals
func get_damage() -> int:
	return damage
