extends CharacterBody2D

# --- Health ---
@export var max_health: int = 100
var health: int = 100

# --- Invincibility window to prevent multi-hit in same frame ---
@onready var damage_delay: Timer = get_node("damage_delay_timer")
var god_mode: bool = false


func _ready() -> void:
	health = max_health
	damage_delay.timeout.connect(_on_damage_delay_timeout)


func take_damage(amount: int) -> void:
	if god_mode:
		return

	health -= amount
	print("Enemy: Took ", amount, " damage | Health remaining: ", health)

	if health <= 0:
		print("Enemy: Destroyed!")
		queue_free()
		return

	god_mode = true
	damage_delay.start()


func _on_damage_delay_timeout() -> void:
	god_mode = false
