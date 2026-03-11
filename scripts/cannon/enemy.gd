extends CharacterBody2D

const CONTEXT = "Enemy"

@export var max_health: int = 100
var health: int = 100

@onready var damage_delay: Timer = get_node("damage_delay_timer")
var god_mode: bool = false

func _ready() -> void:
	# ── ErrorHandler diagnostic block ──────────────────────
	print("ErrorHandler exists: ", is_instance_valid(ErrorHandler))
	print("ErrorHandler node: ", ErrorHandler)
	ErrorHandler.debug("_ready() fired — debug test", CONTEXT)
	ErrorHandler.info("_ready() fired — info test", CONTEXT)
	ErrorHandler.warning("_ready() fired — warning test", CONTEXT)
	ErrorHandler.error("_ready() fired — error test", CONTEXT)
	print("Log path: ", ErrorHandler.LOG_PATH)
	print("Buffer size after calls: ", ErrorHandler._buffer.size())
	ErrorHandler._flush()
	print("Buffer size after flush: ", ErrorHandler._buffer.size())
	print("Log file exists after flush: ", FileAccess.file_exists(ErrorHandler.LOG_PATH))
	# ── End diagnostic block ────────────────────────────────

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
