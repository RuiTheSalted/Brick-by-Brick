extends Node

# --- Score ---
var score: int = 0

# --- Points awarded per brick destroyed (configurable in Inspector) ---
@export var score_per_brick: int = 10

# --- Signal ---
signal score_changed(new_score: int)


func add_score(amount: int) -> void:
	score += amount
	emit_signal("score_changed", score)


func reset_score() -> void:
	score = 0
	emit_signal("score_changed", score)
