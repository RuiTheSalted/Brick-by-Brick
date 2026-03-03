extends CanvasLayer

# Assign your currency texture in the Inspector
@export var currency_texture: Texture2D

# Drag your nodes in directly from the Inspector
@export var currency_label: Label
@export var currency_icon: TextureRect

# Reserved for per-stat upgrade UI — wire these up manually when ready
@export var upgrade_level_label: Label
@export var upgrade_cost_label: Label

# Internal smooth counter
var display_currency: float = 0.0
var target_currency: float = 0.0

# How fast the counter scrolls up/down
@export var count_speed: float = 5.0


func _ready() -> void:
	if currency_icon and currency_texture:
		currency_icon.texture = currency_texture

	call_deferred("_connect_to_currency_manager")
	_update_label()


func _connect_to_currency_manager() -> void:
	if get_tree().root.has_node("CurrencyManager"):
		var cm = get_tree().root.get_node("CurrencyManager")
		cm.currency_changed.connect(_on_currency_changed)
		target_currency = float(cm.currency)
		display_currency = target_currency
		print("HUD: Connected to CurrencyManager successfully")
		_update_label()
	else:
		push_warning("HUD: CurrencyManager not found! Make sure it is added as an AutoLoad.")


func _process(delta: float) -> void:
	if display_currency != target_currency:
		display_currency = move_toward(display_currency, target_currency, abs(target_currency - display_currency) * count_speed * delta + 1.0)
		_update_label()


func _on_currency_changed(new_amount: int) -> void:
	target_currency = float(new_amount)


func _update_label() -> void:
	if currency_label:
		currency_label.text = _format_number(int(display_currency))


# Formats an integer with comma separators e.g. 1500 -> "1,500"
func _format_number(number: int) -> String:
	var s = str(number)
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result
