extends Control

@onready var inGameSettings = $InGameSettings

# Paths to the 5 ball TextureButtons — index matches BallTypeManager type index
const BALL_BUTTON_PATHS: Array[String] = [
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowOne/basicBall",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowTwo/iceBall",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowTwo/beachBall",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowThree/tennisBall",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowThree/cannonBall",
]

# Paths to the price Label inside each ball button
const PRICE_LABEL_PATHS: Array[String] = [
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowOne/basicBall/basicBallPrice",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowTwo/iceBall/iceBallPrice",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowTwo/beachBall/beachBallPrice",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowThree/tennisBall/tennisBallPrice",
	"MarginContainer/stack/selectBallArea/listOfEntitys/vEntryHolder/rowThree/cannonBall/cannonBallPrice",
]

var _ball_buttons: Array = []
var _price_labels: Array = []


func _ready() -> void:
	# Cache nodes and connect ball button signals
	for i in range(BALL_BUTTON_PATHS.size()):
		var btn = get_node_or_null(BALL_BUTTON_PATHS[i])
		_ball_buttons.append(btn)
		if btn:
			btn.pressed.connect(_on_ball_button_pressed.bind(i))

		var lbl = get_node_or_null(PRICE_LABEL_PATHS[i])
		_price_labels.append(lbl)

	# Connect to BallTypeManager to keep visuals in sync
	if get_tree().root.has_node("BallTypeManager"):
		var btm = get_tree().root.get_node("BallTypeManager")
		btm.ball_type_changed.connect(_update_ball_buttons)
		_update_ball_buttons(btm.selected_type)


func _on_ball_button_pressed(type_index: int) -> void:
	if get_tree().root.has_node("BallTypeManager"):
		get_tree().root.get_node("BallTypeManager").try_purchase(type_index)


# Refresh all ball button visuals to reflect current lock/equip state.
func _update_ball_buttons(_changed_index: int) -> void:
	if not get_tree().root.has_node("BallTypeManager"):
		return
	var btm = get_tree().root.get_node("BallTypeManager")

	for i in range(_ball_buttons.size()):
		var btn = _ball_buttons[i]
		var lbl = _price_labels[i]
		if btn == null:
			continue

		if btm.is_unlocked(i):
			btn.modulate = Color(1, 1, 1, 1)  # Full brightness — unlocked
			if lbl:
				lbl.text = "ON" if i == btm.selected_type else ""
		else:
			btn.modulate = Color(0.5, 0.5, 0.5, 1)  # Dimmed — locked
			if lbl:
				lbl.text = "$%d" % btm.BALL_TYPES[i]["price"]


func _on_settings_button_pressed() -> void:
	inGameSettings.show()
	get_tree().paused = true
#checkout brick_spawner and freeze/unfreeze
#fiddle with the upgrades button when able to

func open_upgrade_screen(target: String):
	var stats = get_tree().get_first_node_in_group("gamestats")

	stats.upgrade_target = target

	get_tree().paused = true

	var upgrade_scene = preload("res://scenes/upgradeScreen/upgradeScreen.tscn")
	var upgrade_instance = upgrade_scene.instantiate()

	get_tree().current_scene.add_child(upgrade_instance)

func _on_upgrade_button_pressed():
	open_upgrade_screen("ball")

func _on_cannon_pressed():
	open_upgrade_screen("cannon")
