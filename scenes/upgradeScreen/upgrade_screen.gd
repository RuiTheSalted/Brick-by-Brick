extends Control

# Reference to GameStats so we can read currency, ammo name, and upgrade data
var stats

# Tracks whichever upgrade node the player last clicked
# Empty dict means nothing is selected yet
var selected_upgrade: Dictionary = {}

var selected_path_key: String = ""
var selected_tier: int = -1

# Locked Texture
var locked_texture = preload("res://assets/spritesArt/buttonArt/Locked Path.png")

# POPUPS
@onready var confirmResetPopup = $confirmReset
@onready var confirmResetText = $confirmReset/center/Panel/content/topText
@onready var noUpgradesPopup = $declineReset

# Top + Bottom 
@onready var entityLabel = $VBoxContainer/topBar/ballNameLabel
@onready var currencyLabel = $VBoxContainer/bottomBar/currencyLabel


# Left Panel
@onready var buyButton = $VBoxContainer/upgradePanel/leftPanel/buyButton
@onready var buyButtonText = $VBoxContainer/upgradePanel/leftPanel/buyButton/buyText
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
	confirmResetPopup.confirmed.connect(_on_confirm_reset_popup_confirmed)

# QUICK IF ELSE CHECK TO SEE IF BALL OR CANNON
	if stats.upgrade_target == "ball":
		entityLabel.text = stats.ammo_name # DISPLAY CURRENT ENTITY NAME
		entityArt.texture = stats.ammo_icon # DISPLAY CURRENT ENTITY ICON
	elif stats.upgrade_target == "cannon":
		entityLabel.text = "Cannon"
		entityArt.texture = preload("res://assets/spritesArt/cannon/Cannon_Static_Fix.png")

# Set default state before anything is selected
	clear_left_panel()

	# Load all 9 upgrade node icons and connect their click signals
	# Only runs for balls since cannon upgrades will be different
	if stats.upgrade_target == "ball":
		load_upgrade_nodes()


	# CURRENCY CHANGE LISTENER
	if not stats.currency_changed.is_connected(update_currency):
		stats.currency_changed.connect(update_currency)


func load_upgrade_nodes():
	# Get the upgrade data for whichever ball is currently equipped
	var ball_name = stats.ammo_name
	var ball_upgrades = stats.upgrade_data.get(ball_name, {})
	var chosen_path = stats.chosen_paths.get(ball_name, "")
	var purchased_tier = stats.purchased_tiers.get(ball_name, 0)

	for path_key in upgrade_nodes.keys():
		var path_data = ball_upgrades.get(path_key, [])
		var nodes = upgrade_nodes[path_key]
		var is_locked_path = chosen_path != "" and chosen_path != path_key

		for i in range(nodes.size()):
			var node = nodes[i]

			if i < path_data.size():
				# Assign the upgrade icon to the TextureButton
				var upgrade = path_data[i]
				var is_purchased = (path_key == chosen_path and i < purchased_tier)
				
				if is_locked_path:
					# Wrong path — show locked texture and disable
					node.texture_normal = locked_texture
					node.modulate = Color(0.4, 0.4, 0.4)
					node.disabled = true
				elif is_purchased:
					# Already purchased — show at full brightness
					node.texture_normal = upgrade["icon"]
					node.modulate = Color(1, 1, 1)
					node.disabled = false
				else:
					# Available or locked tier — gray out
					node.texture_normal = upgrade["icon"]
					node.modulate = Color(0.6, 0.6, 0.6)

					# Only enable if previous tier is purchased or this is tier 0
					if i == 0 or (path_key == chosen_path and i <= purchased_tier):
						node.disabled = false
					else:
						node.disabled = true

				# Connect press signal only if not already connected
				if not node.pressed.is_connected(_on_upgrade_pressed.bind(path_key, i)):
					node.pressed.connect(_on_upgrade_pressed.bind(path_key, i))
			else:
				node.disabled = true
				node.modulate = Color(0.3, 0.3, 0.3)


func _on_upgrade_pressed(path_key: String, tier: int):
	var ball_name = stats.ammo_name
	var ball_upgrades = stats.upgrade_data.get(ball_name, {})
	var upgrade = ball_upgrades[path_key][tier]
	var purchased_tier = stats.purchased_tiers.get(ball_name, 0)
	var chosen_path = stats.chosen_paths.get(ball_name, "")
	var already_purchased = (chosen_path == path_key and tier < purchased_tier)

	# Store it so buy button knows what to purchase later
	selected_upgrade = upgrade
	selected_path_key = path_key
	selected_tier = tier

	# Update left panel with this upgrade's info
	upgradeName.text = upgrade["name"]
	upgradeDesc.text = upgrade["desc"]
	entityArt.texture = upgrade["icon"]

	# Update bottom label to show this upgrade's cost vs current currency
	currencyLabel.text = str(upgrade["cost"]) + " / " + str(stats.currency)
	
	
	# Update buy button text
	if already_purchased:
		buyButtonText.text = "Purchased"
		buyButton.disabled = true
	else:
		buyButtonText.text = "Purchase"
		buyButton.disabled = false


func update_currency(_value):
	# Called whenever currency changes via signal
	# If something is selected show its cost, otherwise show placeholder
	if selected_upgrade.is_empty():
		currencyLabel.text = "? / " + str(stats.currency)
	else:
		currencyLabel.text = str(selected_upgrade["cost"]) + " / " + str(stats.currency)


func clear_left_panel():
	buyButton.disabled = false
	currencyLabel.text = "? / " + str(stats.currency)

	var ball_name = stats.ammo_name
	var chosen_path = stats.chosen_paths.get(ball_name, "")
	var purchased_tier = stats.purchased_tiers.get(ball_name, 0)

	if chosen_path != "" and purchased_tier > 0:
		var last_upgrade = stats.upgrade_data[ball_name][chosen_path][purchased_tier - 1]
		entityArt.texture = last_upgrade["icon"]
		upgradeName.text = last_upgrade["name"]
		upgradeDesc.text = last_upgrade["desc"]
		buyButtonText.text = "Purchased"
		buyButton.disabled = true
	else:
		entityArt.texture = stats.ammo_icon
		upgradeName.text = "Select an upgrade"
		upgradeDesc.text = "No upgrade selected"
		buyButtonText.text = "Purchase"
		buyButton.disabled = false


func _on_back_button_pressed():
# BASICALLY UNPAUSES AND SEND BACK TO MAP
	get_tree().paused = false
	queue_free()


func _on_buy_button_pressed():
	if selected_upgrade.is_empty():
		print("No upgrade selected")
		return

	var ball_name = stats.ammo_name
	var purchased_tier = stats.purchased_tiers.get(ball_name, 0)
	var chosen_path = stats.chosen_paths.get(ball_name, "")

	# Can't skip tiers
	if selected_tier > purchased_tier:
		print("Blocked: must buy previous tier")
		return

	# Can't switch paths
	if chosen_path != "" and chosen_path != selected_path_key:
		print("Blocked: path locked")
		return

	# Already purchased
	if chosen_path == selected_path_key and selected_tier < purchased_tier:
		print("Already purchased")
		return

	# Check if player can afford it before attempting
	if stats.currency < selected_upgrade["cost"]:
		print("Not enough currency")
		return

	stats.purchase_upgrade(ball_name, selected_path_key, selected_tier)

# Refresh UI
	load_upgrade_nodes()

# Update button
	buyButtonText.text = "Purchased"
	buyButton.disabled = true


func _on_reset_button_pressed():
	var ball_name = stats.ammo_name
	var purchased_tier = stats.purchased_tiers.get(ball_name, 0)

	if purchased_tier == 0:
		noUpgradesPopup.show()
		return

	# Calculate reset cost to show in popup
	var chosen_path = stats.chosen_paths.get(ball_name, "")
	var last_upgrade = stats.upgrade_data[ball_name][chosen_path][purchased_tier - 1]
	var reset_cost = last_upgrade.get("reset_cost", 0)

	confirmResetText.text = "Reset all upgrades for " + ball_name + "?\nThis will cost " + str(reset_cost) + " currency and cannot be undone."
	confirmResetPopup.show()


func _on_confirm_reset_popup_confirmed():
	var ball_name = stats.ammo_name
	var success = stats.reset_upgrades(ball_name)

	if not success:
		noUpgradesPopup.dialog_text = "Not enough currency to reset."
		noUpgradesPopup.popup_centered()
		return

	# Refresh entire UI back to default state
	load_upgrade_nodes()
	clear_left_panel()
