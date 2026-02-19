extends CharacterBody2D

var _gravity: float = 0.0
var _movement: Vector2 = Vector2.ZERO
var bounce: float = 0.3

func shoot(directional_force: Vector2, gravity: float):
	_movement = directional_force
	_gravity = gravity

func _physics_process(delta):
	# Apply gravity
	_movement.y += _gravity * delta
	
	velocity = _movement
	move_and_slide()

	# Check for collisions AFTER moving
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		
		# bounce physics
		_movement = _movement.bounce(normal) * bounce
		#_movement = normal.reflect(_movement) * bounce
