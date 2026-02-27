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
		return

	health -= amount
	god_mode = true
	damage_delay.start()

	if health <= 0:
		queue_free()


func _on_damage_delay_timeout() -> void:
	god_mode = false
