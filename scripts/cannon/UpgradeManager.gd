extends Node

# --- Per-Stat Upgrade Levels ---
var damage_level: int = 0
var speed_level: int = 0
var bounces_level: int = 0
var ammo_level: int = 0

# --- Base Stats ---
@export var base_damage: int = 1
@export var base_speed: float = 800.0
@export var base_max_bounces: int = 10
@export var base_max_balls: int = 5

# --- Per-Stat Upgrade Costs ---
@export var damage_base_cost: int = 50
@export var speed_base_cost: int = 75
@export var bounces_base_cost: int = 40
@export var ammo_base_cost: int = 100
@export var cost_scaling: float = 1.5

# --- Signals ---
signal damage_upgraded(new_level: int)
signal speed_upgraded(new_level: int)
signal bounces_upgraded(new_level: int)
signal ammo_upgraded(new_level: int)


# Returns the cost of the next upgrade for a given stat
func get_cost(stat: String) -> int:
	match stat:
		"damage":
			return int(damage_base_cost * pow(cost_scaling, damage_level))
		"speed":
			return int(speed_base_cost * pow(cost_scaling, speed_level))
		"bounces":
			return int(bounces_base_cost * pow(cost_scaling, bounces_level))
		"ammo":
			return int(ammo_base_cost * pow(cost_scaling, ammo_level))
	push_error("UpgradeManager: Unknown stat '%s'" % stat)
	return 0


# Attempt to purchase an upgrade for a stat — returns true if successful
func try_upgrade(stat: String) -> bool:
	if not get_tree().root.has_node("CurrencyManager"):
		push_error("UpgradeManager: CurrencyManager not found")
		return false

	var cm = get_tree().root.get_node("CurrencyManager")
	var cost = get_cost(stat)

	if cm.currency < cost:
		print("UpgradeManager: Not enough currency for '", stat, "' upgrade. Need ", cost, ", have ", cm.currency)
		return false

	cm.currency -= cost
	cm.emit_signal("currency_changed", cm.currency)

	match stat:
		"damage":
			damage_level += 1
			print("UpgradeManager: Damage -> level ", damage_level, " | DMG: ", get_damage())
			emit_signal("damage_upgraded", damage_level)
			update_active_balls()
		"speed":
			speed_level += 1
			print("UpgradeManager: Speed -> level ", speed_level, " | SPD: ", snappedf(get_speed(), 0.1))
			emit_signal("speed_upgraded", speed_level)
			update_active_balls()
		"bounces":
			bounces_level += 1
			print("UpgradeManager: Bounces -> level ", bounces_level, " | Max bounces: ", get_max_bounces())
			emit_signal("bounces_upgraded", bounces_level)
			update_active_balls()
		"ammo":
			ammo_level += 1
			print("UpgradeManager: Ammo -> level ", ammo_level, " | Max balls: ", get_max_balls())
			emit_signal("ammo_upgraded", ammo_level)
			update_active_cannons()

	return true


# --- Scaled Stat Getters ---

func get_damage() -> int:
	return base_damage + (damage_level)

func get_speed() -> float:
	return base_speed * pow(1.05, speed_level)

func get_max_bounces() -> int:
	return base_max_bounces + (bounces_level * 2)

func get_max_balls() -> int:
	return base_max_balls + (ammo_level * 2)


# Total upgrades purchased across all stats — used for ball texture tier
func get_total_upgrades() -> int:
	return damage_level + speed_level + bounces_level + ammo_level


# Apply all current stats to a ball instance
func apply_to_ball(ball) -> void:
	ball.damage = get_damage()
	ball.ball_speed = get_speed()
	ball.max_bounces = get_max_bounces()
	if ball.has_method("apply_texture_tier"):
		ball.apply_texture_tier(get_total_upgrades())


# Push current stats to all active balls in the scene
func update_active_balls() -> void:
	var balls = get_tree().get_nodes_in_group("cannonballs")
	for ball in balls:
		apply_to_ball(ball)
	print("UpgradeManager: Updated ", balls.size(), " active ball(s)")


# Push current ammo count to all active cannons in the scene
func update_active_cannons() -> void:
	var cannons = get_tree().get_nodes_in_group("cannons")
	for cannon in cannons:
		if cannon.has_method("sync_ammo"):
			cannon.sync_ammo(get_max_balls())
	print("UpgradeManager: Updated ", cannons.size(), " cannon(s) | Max balls: ", get_max_balls())
