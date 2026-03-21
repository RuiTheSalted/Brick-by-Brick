extends Node

# Signals; When a change occurs, this is called. Helps with scalaility.
signal hp_changed(value)
signal currency_changed(value)
signal round_changed(current, total)
signal ammo_type_changed(name, icon)


# Match State & Starting Variables
var hp: int = 100
var currency: int = 1000

var round_current: int = 1
var round_total: int = 40


# TYPES OF AMMO
var ammo_data := {
	"Basic Ball": {
		"scene": preload("res://scenes/ballsCollision/basicBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/ball.png"),
		"price": 0
	},
	"Ice Ball": {
		"scene": preload("res://scenes/ballsCollision/iceBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/iceball.png"),
		"price": 1000
	},
	"Cannon Ball": {
		"scene": preload("res://scenes/ballsCollision/cannonBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/Cannon_Ball_Big.png"),
		"price": 800
	},
	"Beach Ball": {
		"scene": preload("res://scenes/ballsCollision/beachBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/BeachBall.png"),
		"price": 250
	},
	"Tennis Ball": {
		"scene": preload("res://scenes/ballsCollision/tennisBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/tennisBall.png"),
		"price": 625
	}
}


# WHICH AMMO ARE OWNED (start with basic ball always)
var owned_ammo := {
	"Basic Ball": true
}


var ammo_name: String = "Basic Ball"
var ammo_scene: PackedScene = ammo_data["Basic Ball"]["scene"]
var ammo_icon: Texture2D = ammo_data["Basic Ball"]["icon"]


# Setup
func _ready():
	add_to_group("gamestats")


# HP Setter Function; update Hp & broadcast said new Hp. 
func set_hp(value: int):
	hp = value
	hp_changed.emit(hp)
	
	if hp <= 0:
		trigger_defeat()


# If Lose, Go GameOverScreen
func trigger_defeat():
	get_tree().change_scene_to_file("res://menus/gameOverScreen/gameOverScreen.tscn")


# Currency Add Function; update currency & broadcast said new amount. 
func add_currency(amount: int):
	currency += amount
	currency_changed.emit(currency)


# Currency Spend Function; update currency & broadcast said new amount. 
func spend_currency(amount: int):
	currency -= amount
	currency_changed.emit(currency)


# Next Round Function; Iterate round count & broadcast changes. 
func next_round():
	round_current += 1
	round_changed.emit(round_current, round_total)


# Reset Rounds Function; Start round at one & broadcast changees. 
func reset_round():
	round_current = 1
	round_changed.emit(round_current, round_total)


func buy_ammo(name: String):
	if not ammo_data.has(name):
		return

	if owned_ammo.get(name, false):
		return  # Already owned

	var price = ammo_data[name]["price"]

	if currency >= price:
		spend_currency(price)
		owned_ammo[name] = true


# Ammo Type Function; Update ammo name, icon, and scene, then broadcast changes. 
func set_ammo_type(name: String):
	if not owned_ammo.get(name, false):
		return

	ammo_name = name
	ammo_scene = ammo_data[name]["scene"]
	ammo_icon = ammo_data[name]["icon"]

	ammo_type_changed.emit(ammo_name, ammo_icon)
