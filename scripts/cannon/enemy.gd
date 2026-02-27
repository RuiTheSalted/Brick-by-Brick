extends CharacterBody2D

# Health vars
@export var max_health: int = 100
var health: int = 100

# Damage invincibility timer
@onready var damage_delay: Timer = get_node("damage_delay_timer")
var god_mode: bool = false


func _ready() -> void:
	health = max_health
	damage_delay.timeout.connect(_on_damage_delay_timeout)


# Called directly by the cannonball on collision
func take_damage(amount: int) -> void:
	if god_mode:
		print("Enemy: Hit blocked by god_mode!")
		return

	health -= amount
	print("Enemy: Took ", amount, " damage | Health remaining: ", health)

	if health <= 0:
		print("Enemy: Destroyed!")
		queue_free()
		return

	god_mode = true
	damage_delay.start()
	print("Enemy: God mode activated, timer started")


func _on_damage_delay_timeout() -> void:
	print("Enemy: God mode deactivated")
	god_mode = false
