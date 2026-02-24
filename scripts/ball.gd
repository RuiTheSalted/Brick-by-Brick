extends CharacterBody2D

var speed = 200
var dir = Vector2.DOWN
var is_active = true
var upgrade_level = 0
var total_bounces = 0
var bounces = 0
var ball_health = 10

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
	add_to_group("ball")
	velocity = Vector2(speed * -1, speed)
	
func _physics_process(delta: float) -> void:
	if is_active:
		
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			bounces += 1	# Personal ball bounce count 
			add_bounce() # Global ball count across all balls
			if ball_health <= 0: 
				queue_free()		# Destroy ball
			velocity = velocity.bounce(collision.get_normal())
			var collider = collision.get_collider()
			if collider.is_in_group("bricks"):
				collider.hit()
				ball_health -= 1	# Lose health on brick hits
			else:
				ball_health -= 1	# Lose health on wall hits
			if ball_health <= 0:
				queue_free()
		if (velocity.y > 0 and velocity.y < 100):
			velocity.y = -200
			
		if velocity.x == 0:
			velocity.x = -200

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
