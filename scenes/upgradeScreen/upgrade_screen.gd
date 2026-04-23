extends Control

# Reference to GameStats so we can read currency, ammo name, and upgrade data
var stats

# Tracks whichever upgrade node the player last clicked
# Empty dict means nothing is selected yet
var selected_upgrade: Dictionary = {}

# Top + Bottom 
@onready var entityLabel = $VBoxContainer/topBar/ballNameLabel
@onready var currencyLabel = $VBoxContainer/bottomBar/currencyLabel


# Left Panel
@onready var buyButton = $VBoxContainer/upgradePanel/leftPanel/buyButton
@onready var resetButton = $VBoxContainer/upgradePanel/leftPanel/resetButton
@onready var entityArt = $VBoxContainer/upgradePanel/leftPanel/ballArt
@onready var upgradeName = $VBoxContainer/upgradePanel/leftPanel/upgradeName
@onready var upgradeDesc = $VBoxContainer/upgradePanel/leftPanel/upgradeDescription


# Right Panel
# All 9 upgrades organized by path and tier
# Path = Column, Tier = which row (0 = top, 2 = bottom)
@onready var upgrade_nodes := {
	"path1": [
		$VBoxContainer/upgradePanel/rightPanel/pathOne/upgrade1A,
		$VBoxContainer/upgradePanel/rightPanel/pathOne/upgrade1B,
		$VBoxContainer/upgradePanel/rightPanel/pathOne/upgrade1C,
	],
	"path2": [
		$VBoxContainer/upgradePanel/rightPanel/pathTwo/upgrade2A,
		$VBoxContainer/upgradePanel/rightPanel/pathTwo/upgrade2B,
		$VBoxContainer/upgradePanel/rightPanel/pathTwo/upgrade2C,
	],
	"path3": [
		$VBoxContainer/upgradePanel/rightPanel/pathThree/upgrade3A,
		$VBoxContainer/upgradePanel/rightPanel/pathThree/upgrade3B,
		$VBoxContainer/upgradePanel/rightPanel/pathThree/upgrade3C,
	]
}


func _ready():
	stats = get_tree().get_first_node_in_group("gamestats")

# QUICK IF ELSE CHECK TO SEE IF BALL OR CANNON
	if stats.upgrade_target == "ball":
		entityLabel.text = stats.ammo_name # DISPLAY CURRENT ENTITY NAME
		entityArt.texture = stats.ammo_icon # DISPLAY CURRENT ENTITY ICON
	elif stats.upgrade_target == "cannon":
		entityLabel.text = "Cannon"
		entityArt.texture = preload("res://assets/spritesArt/cannon/Cannon_Static_Fix.png")

# Set default state before anything is selected
	clear_left_panel()


	# Listen for currency changes so bottom label stays accurate
	stats.currency_changed.connect(update_currency)

	# Load all 9 upgrade node icons and connect their click signals
	# Only runs for balls since cannon upgrades will be different
	if stats.upgrade_target == "ball":
		load_upgrade_nodes()


	# CURRENCY CHANGE LISTENER
	if not stats.currency_changed.is_connected(update_currency):
		stats.currency_changed.connect(update_currency)


func load_upgrade_nodes():
	# Get the upgrade data for whichever ball is currently equipped
	var ball_upgrades = stats.upgrade_data.get(stats.ammo_name, {})

	for path_key in upgrade_nodes.keys():
		var path_data = ball_upgrades.get(path_key, [])
		var nodes = upgrade_nodes[path_key]

		for i in range(nodes.size()):
			var node = nodes[i]

			if i < path_data.size():
				# Assign the upgrade icon to the TextureButton
				var upgrade = path_data[i]
				node.texture_normal = upgrade["icon"]
				node.modulate = Color(0.6, 0.6, 0.6) 

				# Connect this node's press to our handler
				# We pass path_key and tier so we know which upgrade was clicked
				node.pressed.connect(_on_upgrade_pressed.bind(path_key, i))
			else:
				# No upgrade data for this slot so disable and dim it
				node.disabled = true
				node.modulate = Color(0.3, 0.3, 0.3)


func _on_upgrade_pressed(path_key: String, tier: int):
	# Look up the specific upgrade that was clicked
	var ball_upgrades = stats.upgrade_data.get(stats.ammo_name, {})
	var upgrade = ball_upgrades[path_key][tier]

	# Store it so buy button knows what to purchase later
	selected_upgrade = upgrade

	# Update left panel with this upgrade's info
	upgradeName.text = upgrade["name"]
	upgradeDesc.text = upgrade["desc"]
	entityArt.texture = upgrade["icon"]

	# Update bottom label to show this upgrade's cost vs current currency
	currencyLabel.text = str(upgrade["cost"]) + " / " + str(stats.currency)


func update_currency(_value):
	# Called whenever currency changes via signal
	# If something is selected show its cost, otherwise show placeholder
	if selected_upgrade.is_empty():
		currencyLabel.text = "? / " + str(stats.currency)
	else:
		currencyLabel.text = str(selected_upgrade["cost"]) + " / " + str(stats.currency)


func clear_left_panel():
	# Default state before anything is clicked
	upgradeName.text = "Select an upgrade"
	upgradeDesc.text = ""
	currencyLabel.text = "? / " + str(stats.currency)


func _on_back_button_pressed():
# BASICALLY UNPAUSES AND SEND BACK TO MAP
	get_tree().paused = false
	queue_free()


func _on_buy_button_pressed():
	pass # upgrade logic comes later


func _on_reset_button_pressed():
	pass # reset logic comes later
