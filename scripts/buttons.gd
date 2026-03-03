extends Node2D

# Which stat this button upgrades — set in the Inspector per button node
# Valid values: "damage", "speed", "bounces", "ammo"
@export var upgrade_stat: String = "damage"

# Set to true while testing so upgrades are free
@export var debug_free_upgrades: bool = false


func _on_upgrade_button_pressed() -> void:
	if not get_tree().root.has_node("UpgradeManager"):
		print("Error: UpgradeManager not found")
		return

	var um = get_tree().root.get_node("UpgradeManager")

	# Debug mode: bypass cost check entirely
	if debug_free_upgrades:
		match upgrade_stat:
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
		print("DEBUG: Free '", upgrade_stat, "' upgrade applied")
		return

	# Normal path: deduct currency and apply upgrade
	print("Attempting '", upgrade_stat, "' upgrade | Currency: ",
		get_tree().root.get_node("CurrencyManager").currency,
		" | Cost: ", um.get_cost(upgrade_stat))

	var success = um.try_upgrade(upgrade_stat)

	if not success:
		print("Upgrade failed — need ", um.get_cost(upgrade_stat),
			" but have ", get_tree().root.get_node("CurrencyManager").currency)
