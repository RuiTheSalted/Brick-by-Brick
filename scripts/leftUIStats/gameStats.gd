extends Node

# Signals; When a change occurs, this is called. Helps with scalaility.
signal hp_changed(value)
signal currency_changed(value)
signal round_changed(current, total)
signal ammo_type_changed(name, icon)


# TYPES OF AMMO
var ammo_data := {
	"Basic Ball": {
		"scene": preload("res://scenes/ballsCollision/basicBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/ball.png"),
		"price": 0,
		"damage": 1,
		"bounces": 5,
		"speed": 800.0, 
		"size": 1.0, 
		"shootSpeed": 0.5
	},
	"Ice Ball": {
		"scene": preload("res://scenes/ballsCollision/iceBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/iceball.png"),
		"price": 1000,
		"damage": 1,
		"bounces": 5,
		"speed": 800.0, 
		"size": 1.0, 
		"shootSpeed": 1.0,
		"lavaResist": true,
		"slowEffect": true
	},
	"Cannon Ball": {
		"scene": preload("res://scenes/ballsCollision/cannonBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/Cannon_Ball_Big.png"),
		"price": 800,
		"damage": 4,
		"bounces": 1,
		"speed": 600.0,
		"size": 1.25,
		"shootSpeed": 2.0
	},
	"Beach Ball": {
		"scene": preload("res://scenes/ballsCollision/beachBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/BeachBall.png"),
		"price": 250,
		"damage": 1,
		"bounces": 15,
		"speed": 400.0,
		"size": 2.0,
		"shootSpeed": 3.0
	},
	"Tennis Ball": {
		"scene": preload("res://scenes/ballsCollision/tennisBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/tennisBall.png"),
		"price": 625,
		"damage": 1,
		"bounces": 7,
		"speed": 1200.0, 
		"size": 0.5,
		"shootSpeed": 0.667
	}
}


var upgrade_data := {
	"Basic Ball": {
		"path1": [
			{"name": "Basic Ball +", "desc": "Added red strip gives the Basic Ball a harder impact.", "cost": 550, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 1-1.png")},
			{"name": "Basic Ball ++", "desc": "Added X improves impact, while red strip is repurposed into bouncing improvements.", "cost": 1800, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 1-2.png")},
			{"name": "Basic Ball X", "desc": "Red material coats the Basic Ball adding even more damage as well as making firing easier on the cannon.", "cost": 4300, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 1-3.png")},
		],
		"path2": [
			{"name": "Improved Materials", "desc": "Green strip makes firing Basic Ball easier on the cannon.", "cost": 650, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 2-1.png")},
			{"name": "Optimized Ball", "desc": "Further optimized Basic Balls allowing for harder impacts while also improving fire speed.", "cost": 2000, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 2-2.png")},
			{"name": "Basic Ball Y", "desc": "Green material coats the Basic Ball allowing for even faster firing, and better bounce capabilities.", "cost": 4100, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 2-3.png")},
		],
		"path3": [
			{"name": "Upgrade 3-1", "desc": "3-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-1.png")},
			{"name": "Upgrade 3-2", "desc": "3-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-2.png")},
			{"name": "Upgrade 3-3", "desc": "3-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-3.png")},
		]
	},
	"Ice Ball": {
		"path1": [
			{"name": "Upgrade 1-1", "desc": "1-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-1.png")},
			{"name": "Upgrade 1-2", "desc": "1-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-2.png")},
			{"name": "Upgrade 1-3", "desc": "1-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-3.png")},
		],
		"path2": [
			{"name": "Upgrade 2-1", "desc": "2-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 2-1.png")},
			{"name": "Upgrade 2-2", "desc": "2-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 2-2.png")},
			{"name": "Upgrade 2-3", "desc": "2-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 2-3.png")},
		],
		"path3": [
			{"name": "Upgrade 3-1", "desc": "3-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 3-1.png")},
			{"name": "Upgrade 3-2", "desc": "3-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 3-2.png")},
			{"name": "Upgrade 3-3", "desc": "3-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 3-3.png")},
		]
	},
	"Cannon Ball": {
		"path1": [
			{"name": "Upgrade 1-1", "desc": "1-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-1.png")},
			{"name": "Upgrade 1-2", "desc": "1-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-2.png")},
			{"name": "Upgrade 1-3", "desc": "1-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-3.png")},
		],
		"path2": [
			{"name": "Upgrade 2-1", "desc": "2-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-1.png")},
			{"name": "Upgrade 2-2", "desc": "2-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-2.png")},
			{"name": "Upgrade 2-3", "desc": "2-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-3.png")},
		],
		"path3": [
			{"name": "Upgrade 3-1", "desc": "3-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-1.png")},
			{"name": "Upgrade 3-2", "desc": "3-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-2.png")},
			{"name": "Upgrade 3-3", "desc": "3-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-3.png")},
		]
	},
	"Beach Ball": {
		"path1": [
			{"name": "Upgrade 1-1", "desc": "1-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-1.png")},
			{"name": "Upgrade 1-2", "desc": "1-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-2.png")},
			{"name": "Upgrade 1-3", "desc": "1-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-3.png")},
		],
		"path2": [
			{"name": "Upgrade 2-1", "desc": "2-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-1.png")},
			{"name": "Upgrade 2-2", "desc": "2-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-2.png")},
			{"name": "Upgrade 2-3", "desc": "2-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-3.png")},
		],
		"path3": [
			{"name": "Upgrade 3-1", "desc": "3-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-1.png")},
			{"name": "Upgrade 3-2", "desc": "3-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-2.png")},
			{"name": "Upgrade 3-3", "desc": "3-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-3.png")},
		]
	},
	"Tennis Ball": {
		"path1": [
			{"name": "Upgrade 1-1", "desc": "1-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-1.png")},
			{"name": "Upgrade 1-2", "desc": "1-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-2.png")},
			{"name": "Upgrade 1-3", "desc": "1-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-3.png")},
		],
		"path2": [
			{"name": "Upgrade 2-1", "desc": "2-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-1.png")},
			{"name": "Upgrade 2-2", "desc": "2-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-2.png")},
			{"name": "Upgrade 2-3", "desc": "2-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-3.png")},
		],
		"path3": [
			{"name": "Upgrade 3-1", "desc": "3-1 desc", "cost": 100, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-1.png")},
			{"name": "Upgrade 3-2", "desc": "3-2 desc", "cost": 200, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-2.png")},
			{"name": "Upgrade 3-3", "desc": "3-3 desc", "cost": 300, "icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-3.png")},
		]
	}
}

# WHICH AMMO ARE OWNED (start with basic ball always)
var owned_ammo := {
	"Basic Ball": true
}

# Match State & Starting Variables
var hp: int = 100
var currency: int = 20000

var round_current: int = 1
var round_total: int = 40

var ammo_name: String = "Basic Ball"
var ammo_icon: Texture2D = ammo_data["Basic Ball"]["icon"]
var ammo_scene: PackedScene = ammo_data["Basic Ball"]["scene"]

var upgrade_target: String = "ball"

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


func buy_ammo(ammo_name_str: String):
	if not ammo_data.has(ammo_name_str):
		return

	if owned_ammo.get(ammo_name_str, false):
		return  # Already owned

	var price = ammo_data[ammo_name_str]["price"]

	if currency >= price:
		spend_currency(price)
		owned_ammo[ammo_name_str] = true


# Ammo Type Function; Update ammo name, icon, and scene, then broadcast changes. 
func set_ammo_type(ammo_name_str: String):
	if not owned_ammo.get(ammo_name_str, false):
		return

	ammo_name = ammo_name_str
	ammo_scene = ammo_data[ammo_name_str]["scene"]
	ammo_icon = ammo_data[ammo_name_str]["icon"]

	ammo_type_changed.emit(ammo_name, ammo_icon)
