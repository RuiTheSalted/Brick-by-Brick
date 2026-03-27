extends Control

var stats

# VARIABLES 
@onready var entityLabel = $VBoxContainer/topBar/ballNameLabel
@onready var currencyLabel = $VBoxContainer/bottomBar/currencyLabel
@onready var buyButton = $VBoxContainer/upgradePanel/leftPanel/buyButton
@onready var resetButton = $VBoxContainer/upgradePanel/leftPanel/resetButton
@onready var entityArt = $VBoxContainer/upgradePanel/leftPanel/ballArt


func _ready():
	stats = get_tree().get_first_node_in_group("gamestats")

# QUICK IF ELSE CHECK TO SEE IF BALL OR CANNON
	if stats.upgrade_target == "ball":
		# DISPLAY CURRENT ENTITY NAME
		entityLabel.text = stats.ammo_name
		# DISPLAY CURRENT ENTITY ICON
		entityArt.texture = stats.ammo_icon

	elif stats.upgrade_target == "cannon":
		entityLabel.text = "Cannon"
		entityArt.texture = preload("res://assets/spritesArt/cannon/Cannon_Static_Fix.png")

	# DISPLAY CURRENCY
	update_currency(stats.currency)

	# CURRENCY CHANGE LISTENER
	stats.currency_changed.connect(update_currency)


func update_currency(value):
# UPGRADE COST / TOTAL CURRENCY
	currencyLabel.text = str(value) + " / " + str(stats.currency)


func _on_back_button_pressed():
# BASICALLY UNPAUSES AND SEND BACK TO MAP
	get_tree().paused = false
	queue_free()


func _on_buy_button_pressed():
	pass # upgrade logic comes later


func _on_reset_button_pressed():
	pass # reset logic comes later
