extends Node

# --- Currency ---
var currency: int = 0

# --- Upgrade ---
var upgrade_level: int = 0

# --- Upgrade Cost Scaling ---
@export var base_cost: int = 100
@export var cost_scaling: float = 1.5

# --- Signal ---
signal currency_changed(new_amount)
signal upgrade_purchased(new_level)


# Add currency from ball hits
func add_currency(amount: int) -> void:
	currency += amount
	print("CurrencyManager: +", amount, " currency | Total: ", currency)
	emit_signal("currency_changed", currency)


# Returns the cost of the next upgrade
func get_upgrade_cost() -> int:
	return int(base_cost * pow(cost_scaling, upgrade_level))


# Try to purchase an upgrade — returns true if successful
func try_upgrade() -> bool:
	var cost = get_upgrade_cost()
	if currency < cost:
		print("CurrencyManager: Not enough currency! Need ", cost, " have ", currency)
		return false

	currency -= cost
	upgrade_level += 1
	print("CurrencyManager: Upgrade purchased! Level ", upgrade_level, " | Cost was ", cost, " | Remaining: ", currency)
	emit_signal("currency_changed", currency)
	emit_signal("upgrade_purchased", upgrade_level)

	# Update all active balls in the scene
	_update_active_balls()
	return true


# Push new upgrade level to all balls currently in the scene
func _update_active_balls() -> void:
	var balls = get_tree().get_nodes_in_group("ball")
	for ball in balls:
		if ball.has_method("set_upgrade_level"):
			ball.set_upgrade_level(upgrade_level)
	print("CurrencyManager: Updated ", balls.size(), " active ball(s) to level ", upgrade_level)


# Helper — print current state (useful for debugging)
func print_status() -> void:
	print("--- CurrencyManager Status ---")
	print("Currency: ", currency)
	print("Upgrade Level: ", upgrade_level)
	print("Next Upgrade Cost: ", get_upgrade_cost())
	print("------------------------------")
