extends Control

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


func update_hp(value):
	$MarginContainer/stack/healthSection/healthRow/healthNumber.text = str(value)


func update_currency(value):
	$MarginContainer/stack/currencySection/currencyRow/currencyNumber.text = str(value)


func update_round(current, total):
	$MarginContainer/stack/roundSection/roundRow/roundCounter.text = "Round:\n" + str(current) + "/" + str(total)


func update_ammo(name, icon):
	$MarginContainer/stack/ammoSection/ammoRow/ammoName.text = name
	$MarginContainer/stack/ammoSection/ammoRow/ammoIcon.texture = icon
