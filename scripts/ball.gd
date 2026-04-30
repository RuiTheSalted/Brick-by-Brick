extends CharacterBody2D

signal ball_died

# Identier for ball
var ball_type: String = "Basic Ball"
var ignore_lava: bool = false
var slow_effect: bool = false

var damage: int = 1
var ball_speed: float = 800.0
var max_bounces: int = 10
var bounce_count: int = 0

var gravity: float = 0.0
var is_active: bool = true

var buildup_active = false
var buildup_bonus = 0
var buildup_per_bounce = 1

var weakening_effect: bool = false


@onready var sprite = $Sprite2D

func _ready():
	add_to_group("ball")

	var stats = get_tree().get_first_node_in_group("gamestats")

	if stats and stats.ability_active and stats.ability_name == "buildup":
		buildup_active = true
		buildup_per_bounce = stats.buildup_per_bounce


func _physics_process(delta: float) -> void:
	if not is_active:
		return

	velocity.y += gravity * delta
	
	var collision = move_and_collide(velocity * delta)

	if collision:
		# Audio queue
		AudioManager.play_ball_sfx(ball_type)
		
		var collider = collision.get_collider()
		var brick = collider if collider.is_in_group("bricks") else collider.get_parent()

		if brick and brick.is_in_group("bricks"):
			var total_damage = damage

			if buildup_active:
				total_damage += buildup_bonus
				buildup_bonus += buildup_per_bounce

			# Apply damage once
			brick.take_damage(total_damage)

			var stats = get_tree().get_first_node_in_group("gamestats")

			# Apply freeze effect
			if slow_effect and brick.has_method("apply_slow") and stats:
				var duration = stats.ammo_data[stats.ammo_name].get("freezeDuration", 2.0)
				var strength = stats.ammo_data[stats.ammo_name].get("freezeStrength", -1.0)

				# Main brick
				brick.apply_slow(duration, strength)

				# Nearby bricks
				_apply_freeze_radius(brick, duration, strength)
			# Apply weakness effect
			if weakening_effect and brick.has_method("apply_weakness"):
				brick.apply_weakness()

			# Apply knockback effect
			if stats and stats.ability_name == "knockbackBall" and stats.knockback_hits_remaining > 0:
				if brick.get_parent() is PathFollow2D:
					var path_follow = brick.get_parent()

					# Push backward
					var force = stats.ammo_data[stats.ammo_name].get("knockback_force", 80)
					path_follow.progress -= force
					if path_follow.progress < 0:
						path_follow.progress = 0

				stats.knockback_hits_remaining -= 1

				# End ability when used up
				if stats.knockback_hits_remaining <= 0:
					stats.ability_active = false
					stats.knockback_hits_remaining = 0

			# Lava check AFTER everything
			if brick.is_lava() and not ignore_lava:
				ball_died.emit()
				queue_free()
				return

		bounce_count += 1

		if bounce_count >= max_bounces:
			ball_died.emit()
			queue_free()
			return

		velocity = velocity.bounce(collision.get_normal())

		# PUSH BALL OUT OF COLLISION (fixes sticking)
		position += collision.get_normal() * 4.0


func shoot(force: Vector2, grav: float) -> void:
	velocity = force.normalized() * ball_speed
	gravity = grav
	is_active = true


func _apply_freeze_radius(hit_brick: Node, duration: float, strength: float) -> void:
	var stats = get_tree().get_first_node_in_group("gamestats")
	if not stats:
		return

	var radius = stats.ammo_data[stats.ammo_name].get("freezeRadius", 0.0)
	if radius <= 0.0:
		return

	for other_brick in get_tree().get_nodes_in_group("bricks"):
		if other_brick == hit_brick:
			continue
		if not other_brick.has_method("apply_slow"):
			continue

		var distance = hit_brick.global_position.distance_to(other_brick.global_position)
		if distance <= radius:
			other_brick.apply_slow(duration, strength)
