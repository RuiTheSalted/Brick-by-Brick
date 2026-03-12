extends Node2D

@export var debug_free_upgrades: bool = false

@onready var damage_button: Button = $VBoxContainer/DamageButton
@onready var speed_button: Button = $VBoxContainer/SpeedButton
@onready var bounces_button: Button = $VBoxContainer/BouncesButton
@onready var ammo_button: Button = $VBoxContainer/AmmoButton


func _ready() -> void:
	damage_button.pressed.connect(_on_damage_pressed)
	speed_button.pressed.connect(_on_speed_pressed)
	bounces_button.pressed.connect(_on_bounces_pressed)
	ammo_button.pressed.connect(_on_ammo_pressed)
	_update_labels()


func _update_labels() -> void:
	if not get_tree().root.has_node("UpgradeManager"):
		return
	var um = get_tree().root.get_node("UpgradeManager")
	damage_button.text = "Damage\nCost: %d" % um.get_cost("damage")
	speed_button.text = "Speed\nCost: %d" % um.get_cost("speed")
	bounces_button.text = "Bounces\nCost: %d" % um.get_cost("bounces")
	ammo_button.text = "Ammo\nCost: %d" % um.get_cost("ammo")


func _try_upgrade(stat: String) -> void:
	if not get_tree().root.has_node("UpgradeManager"):
		print("Error: UpgradeManager not found")
		return

	var um = get_tree().root.get_node("UpgradeManager")

	if debug_free_upgrades:
		match stat:
			"damage":
				um.damage_level += 1
				um.emit_signal("damage_upgraded", um.damage_level)
				um.update_active_balls()
			"speed":
				um.speed_level += 1
				um.emit_signal("speed_upgraded", um.speed_level)
				um.update_active_balls()
			"bounces":
				um.bounces_level += 1
				um.emit_signal("bounces_upgraded", um.bounces_level)
				um.update_active_balls()
			"ammo":
				um.ammo_level += 1
				um.emit_signal("ammo_upgraded", um.ammo_level)
				um.update_active_cannons()
		print("DEBUG: Free '", stat, "' upgrade applied")
		_update_labels()
		return

	print("Attempting '", stat, "' upgrade | Currency: ",
		get_tree().root.get_node("CurrencyManager").currency,
		" | Cost: ", um.get_cost(stat))

	var success = um.try_upgrade(stat)

	if not success:
		print("Upgrade failed — need ", um.get_cost(stat),
			" but have ", get_tree().root.get_node("CurrencyManager").currency)

	_update_labels()


func _on_damage_pressed() -> void:
	_try_upgrade("damage")

func _on_speed_pressed() -> void:
	_try_upgrade("speed")

func _on_bounces_pressed() -> void:
	_try_upgrade("bounces")

func _on_ammo_pressed() -> void:
	_try_upgrade("ammo")
