extends Node

# --- Currency ---
var currency: int = 10000

# --- Signal ---
signal currency_changed(new_amount)


# Add currency from ball hits
func add_currency(amount: int) -> void:
	currency += amount
	emit_signal("currency_changed", currency)
