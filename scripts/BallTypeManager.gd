# BallTypeManager.gd
# Autoload singleton for ball type selection in levelWithUi.
# Players purchase a ball type once per session to unlock it, then can freely equip it.

extends Node

# Ball type data — index matches the UI button order in rightHud
const BALL_TYPES: Array[Dictionary] = [
	{"name": "Basic Ball",  "texture_path": "res://assets/spritesArt/ball/ball.png",              "price": 0},
	{"name": "Ice Ball",    "texture_path": "res://assets/spritesArt/ball/iceball.png",           "price": 650},
	{"name": "Beach Ball",  "texture_path": "res://assets/spritesArt/ball/BeachBall.png",         "price": 600},
	{"name": "Tennis Ball", "texture_path": "res://assets/spritesArt/ball/tennisBall.png",        "price": 700},
	{"name": "Cannon Ball", "texture_path": "res://assets/spritesArt/ball/Cannon_Ball_Big.png",   "price": 1000},
]

# Basic Ball (index 0) starts unlocked; others require purchase
var unlocked: Array[bool] = [true, false, false, false, false]
var selected_type: int = 0

signal ball_type_changed(type_index: int)

var _textures: Array[Texture2D] = []


func _ready() -> void:
	_textures.resize(BALL_TYPES.size())
	for i in range(BALL_TYPES.size()):
		var path: String = BALL_TYPES[i]["texture_path"]
		if ResourceLoader.exists(path):
			_textures[i] = load(path)
		else:
			push_warning("BallTypeManager: Texture not found: %s" % path)


func get_selected_texture() -> Texture2D:
	if selected_type < _textures.size():
		return _textures[selected_type]
	return null


func is_unlocked(type_index: int) -> bool:
	return type_index >= 0 and type_index < unlocked.size() and unlocked[type_index]


# Purchase and equip a ball type. If already owned, just equips it. Returns true on success.
func try_purchase(type_index: int) -> bool:
	if type_index < 0 or type_index >= BALL_TYPES.size():
		push_error("BallTypeManager: Invalid type index %d" % type_index)
		return false

	if is_unlocked(type_index):
		select_type(type_index)
		return true

	var price: int = BALL_TYPES[type_index]["price"]

	if price == 0:
		unlocked[type_index] = true
		select_type(type_index)
		return true

	if not get_tree().root.has_node("CurrencyManager"):
		push_error("BallTypeManager: CurrencyManager not found")
		return false

	var cm = get_tree().root.get_node("CurrencyManager")
	if cm.currency < price:
		print("BallTypeManager: Not enough currency for '%s'. Need %d, have %d" % [
			BALL_TYPES[type_index]["name"], price, cm.currency
		])
		return false

	cm.currency -= price
	cm.emit_signal("currency_changed", cm.currency)
	unlocked[type_index] = true
	select_type(type_index)
	return true


# Equip an already-unlocked ball type.
func select_type(type_index: int) -> void:
	if not is_unlocked(type_index):
		push_warning("BallTypeManager: Cannot equip locked type %d" % type_index)
		return
	selected_type = type_index
	emit_signal("ball_type_changed", type_index)
	print("BallTypeManager: Equipped '%s'" % BALL_TYPES[type_index]["name"])
