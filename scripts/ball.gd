extends CharacterBody2D

signal ball_died

var speed = 200
var dir = Vector2.DOWN
var is_active = true
var upgrade_level = 0
var total_bounces = 0
var bounces = 0
var ball_health = 10
var gravity = 0

# Array of textures for different upgrade levels
var ball_textures = [
	"res://assets/spritesArt/ball/tennisBall.png",
	"res://assets/spritesArt/ball/iceball.png",
]

# Base scale for each texture to make them the same visual size
var ball_scales = [
	Vector2(0.1, 0.1),   # ball.png scale
	Vector2(0.15, 0.15), # iceball.png scale - adjust this value as needed
]

@onready var sprite = $Sprite2D

func _ready() -> void:
	print("BALL READY - script is loaded correctly")
	add_to_group("ball")
	velocity = Vector2(speed * -1, speed)
	
func _physics_process(delta: float) -> void:
	if is_active:
		
		velocity.y += gravity * delta
		
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			
			var collider = collision.get_collider()
			var brick = collider.get_parent() if not collider.is_in_group("bricks") else collider
				
			if brick.is_in_group("bricks"):
						# Lava brick destroys the ball instantly
				if brick.has_method("is_lava") and brick.is_lava():
					print("lava brick hit!")
					brick.take_damage(1, self)
					ball_died.emit()
					queue_free()
					return
					
				# Normal brick damage
				brick.take_damage(1, self)
				ball_health -= 1
			else:
				ball_health -= 1
			if ball_health <= 0:
				ball_died.emit()
				queue_free()
				return
				
			velocity = velocity.bounce(collision.get_normal())
		

func add_bounce() -> void:
	total_bounces += 1
	print("Total bounces: ", total_bounces)

func upgrade() -> void:
	upgrade_level += 1
	print("Ball upgraded to level ", upgrade_level)
	
	# Update texture if available
	var texture_index = min(upgrade_level, ball_textures.size() - 1)
	var new_texture = load(ball_textures[texture_index])
	if new_texture:
		sprite.texture = new_texture
	
	# Optionally increase ball size with upgrades
	var scale_increase = 1.5 + (upgrade_level * 0.05)
	var base_scale = ball_scales[texture_index] if texture_index < ball_scales.size() else Vector2(0.1, 0.1)
	sprite.scale = base_scale * scale_increase
	
	# Optionally increase speed with upgrades
	speed = 200 + (upgrade_level * 20)
	velocity = velocity.normalized() * speed
	
func shoot(force: Vector2, grav: float):
	velocity = force
	gravity = grav
