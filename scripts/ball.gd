extends CharacterBody2D

signal ball_died

var ignore_lava: bool = false
var slow_effect: bool = false

var damage: int = 1
var ball_speed: float = 800.0
var max_bounces: int = 10
var bounce_count: int = 0

var gravity: float = 0.0
var is_active: bool = true

@onready var sprite = $Sprite2D

func _ready() -> void:
	add_to_group("ball")

func _physics_process(delta: float) -> void:
	if not is_active:
		return

	velocity.y += gravity * delta

	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		var brick = collider if collider.is_in_group("bricks") else collider.get_parent()
		if brick and brick.is_in_group("bricks"):
			if brick.is_lava():
				brick.take_damage(damage)
				if slow_effect and brick.has_method("apply_slow"):
						brick.apply_slow()
				if not ignore_lava:
					ball_died.emit()
					queue_free()
					return
			else: 
				brick.take_damage(damage)
				if slow_effect and brick.has_method("apply_slow"):
					brick.apply_slow()

		bounce_count += 1

		if bounce_count >= max_bounces:
			ball_died.emit()
			queue_free()
			return

		velocity = velocity.bounce(collision.get_normal())
		# PUSH BALL OUT OF COLLISION (fixes sticking, still not perfect)
		position += collision.get_normal() * 4.0

func shoot(force: Vector2, grav: float) -> void:
	velocity = force.normalized() * ball_speed
	gravity = grav
	is_active = true
