extends CharacterBody2D

# Cannon settings
@export var cannon_velocity: float = 800.0
@export var cannon_gravity: float = 500.0
@export var cannon_delay: float = 0.25

# Bullet Scene
@export var cannon_scene: PackedScene

# Spawn position (Marker2D or Node2D at cannon tip)
@export var cannonBall_spawn: Node2D

# Sound + Animation
@export var cannon_sound: AudioStreamPlayer2D
@export var anim_player: AnimationPlayer

# Internal state
var waited: float = 0.0
var shooting: bool = false

func _process(delta):
	var direction = get_global_mouse_position() - global_position
	rotation = direction.angle() + PI / 2

	waited += delta

	if shooting and waited >= cannon_delay:
		shoot()
		waited = 0.0


func _input(event):
	if event.is_action_pressed("ui_select"):
		shooting = true
	elif event.is_action_released("ui_select"):
		shooting = false

func shoot():
	if cannon_scene == null:
		return
	
	var cannonball = cannon_scene.instantiate()
	
	# Set spawn position
	cannonball.global_position = cannonBall_spawn.global_position
	
	# Calculate direction to mouse
	var direction = (get_global_mouse_position() - cannonball.global_position).normalized()
	
	# Call cannonball's shoot function
	cannonball.shoot(direction * cannon_velocity, cannon_gravity)
	
	get_parent().add_child(cannonball)

	# Play animation
	if anim_player:
		anim_player.play("shake")

	# Play sound
	if cannon_sound:
		cannon_sound.pitch_scale = randf_range(0.95, 1.05)
		cannon_sound.play()
