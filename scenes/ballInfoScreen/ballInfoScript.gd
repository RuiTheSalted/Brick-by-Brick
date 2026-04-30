extends Control

var caller_screen: Control = null

var stats
var ball_name: String = ""

# Top
@onready var ballNameLabel = $VBoxContainer/topBar/ballNameLabel

# Left Panel
@onready var ballArt = $VBoxContainer/upgradePanel/leftPanel/ballArt
@onready var upgradeName = $VBoxContainer/upgradePanel/leftPanel/upgradeName
@onready var upgradeDesc = $VBoxContainer/upgradePanel/leftPanel/upgradeDescription

# Right Panel
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
	ball_name = stats.info_target_ball

	ballNameLabel.text = ball_name

	# Show base ball art
	if stats.ammo_data.has(ball_name):
		ballArt.texture = stats.ammo_data[ball_name]["icon"]

	# Set default left panel state
	upgradeName.text = "Select an upgrade"
	upgradeDesc.text = "Click any upgrade to see its details"

	load_upgrade_nodes()


func load_upgrade_nodes():
	var ball_upgrades = stats.upgrade_data.get(ball_name, {})

	for path_key in upgrade_nodes.keys():
		var path_data = ball_upgrades.get(path_key, [])
		var nodes = upgrade_nodes[path_key]

		for i in range(nodes.size()):
			var node = nodes[i]

			if i < path_data.size():
				var upgrade = path_data[i]

				# Show icon at slightly grayed out — info only, nothing purchased
				node.texture_normal = upgrade["icon"]
				node.modulate = Color(0.85, 0.85, 0.85)
				node.disabled = false

				# Connect click to show info
				if not node.pressed.is_connected(_on_upgrade_pressed.bind(path_key, i)):
					node.pressed.connect(_on_upgrade_pressed.bind(path_key, i))
			else:
				node.disabled = true
				node.modulate = Color(0.3, 0.3, 0.3)


func _on_upgrade_pressed(path_key: String, tier: int):
	var ball_upgrades = stats.upgrade_data.get(ball_name, {})
	var upgrade = ball_upgrades[path_key][tier]

	# Update left panel — name and desc only, no cost
	upgradeName.text = upgrade["name"]
	upgradeDesc.text = upgrade["desc"]
	ballArt.texture = upgrade["icon"]


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://menus/ballsScreen/ballsScreen.tscn")
