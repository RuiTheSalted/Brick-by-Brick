extends Control

@onready var cooldown_overlay = $MarginContainer/stack/ammoSection/ammoRow/ammoIcon/cooldownOverlay

# DEFINE STATS VARIABLE
var stats


# RUN WHEN SCENE RUNS
func _ready():
# REFERENCE GAMESTATS WITH VARIABLE STATS (note; works when you RUN levelWithUI ONLY)
	stats = get_tree().get_first_node_in_group("gamestats")

# CONNECT ALL SIGNALS HERE (ex: when hp_changed is emitted, call update_hp)
	stats.hp_changed.connect(update_hp)
	stats.currency_changed.connect(update_currency)
	stats.round_changed.connect(update_round)
	stats.ammo_type_changed.connect(update_ammo)

	# MANUALLY INITIAlIZE UI WITH STARTER VALUES ONCE (starting values)
	update_hp(stats.hp)
	update_currency(stats.currency)
	update_round(stats.round_current, stats.round_total)
	update_ammo(stats.ammo_name, stats.ammo_icon)


func _process(_delta):
	if not stats:
		return

	# If on cooldown
	if stats.ability_cooldown_timer > 0:
		var percent = stats.ability_cooldown_timer / stats.ability_cooldown
		cooldown_overlay.value = clamp(1.0 - percent, 0.0, 1.0)
		cooldown_overlay.visible = true
	else:
		cooldown_overlay.visible = false


func update_hp(value):
	$MarginContainer/stack/healthSection/healthRow/healthNumber.text = str(value)


func update_currency(value):
	$MarginContainer/stack/currencySection/currencyRow/currencyNumber.text = str(value)


func update_round(current, total):
	$MarginContainer/stack/roundSection/roundRow/roundCounter.text = "Round:\n" + str(current) + "/" + str(total)


func update_ammo(ammo_name, icon):
	$MarginContainer/stack/ammoSection/ammoRow/ammoName.text = ammo_name

	var icon_node = $MarginContainer/stack/ammoSection/ammoRow/ammoIcon

	# Check if this ball has an upgraded icon (ability)
	if stats.ability_name != "" and stats.ammo_data[ammo_name].has("currentIcon"):
		icon_node.texture_normal = stats.ammo_data[ammo_name]["currentIcon"]
		icon_node.texture_hover = stats.ammo_data[ammo_name]["currentIcon"]
		icon_node.texture_pressed = stats.ammo_data[ammo_name]["currentIcon"]
	else:
		icon_node.texture_normal = icon
		icon_node.texture_hover = icon
		icon_node.texture_pressed = icon


func _on_ammo_icon_pressed():
	print("ICON CLICKED")

	if not stats:
		return

	print("Ability name:", stats.ability_name)

	if stats.ability_name != "" and stats.ability_cooldown_timer <= 0:
		stats.activate_ability()
