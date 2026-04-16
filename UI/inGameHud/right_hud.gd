extends Control

var stats

@onready var inGameSettings = $InGameSettings
@onready var selectedEntityName = $MarginContainer/stack/selectedEntity/entityName


func _ready() -> void:
	#GET STATS FOR NAME CHANGING LATER & SET STARTING NAME
	stats = get_tree().get_first_node_in_group("gamestats")
	selectedEntityName.text = stats.ammo_name
	stats.ammo_type_changed.connect(update_Selected_Ball_Text)


func update_Selected_Ball_Text(_name, _icon):
	print("Signal fired")
	print("ammo_name:", stats.ammo_name)
	selectedEntityName.text = stats.ammo_name


func _on_settings_button_pressed() -> void:
	inGameSettings.show()
	get_tree().paused = true
	#checkout brick_spawner and freeze/unfreeze
	#fiddle with the upgrades button when able to


func open_upgrade_screen(target: String):
	stats.upgrade_target = target
	get_tree().paused = true
	var upgrade_scene = preload("res://scenes/upgradeScreen/upgradeScreen.tscn")
	var upgrade_instance = upgrade_scene.instantiate()

	get_tree().current_scene.add_child(upgrade_instance)


func _on_upgrade_button_pressed():
	open_upgrade_screen("ball")


func _on_cannon_pressed():
	open_upgrade_screen("cannon")
