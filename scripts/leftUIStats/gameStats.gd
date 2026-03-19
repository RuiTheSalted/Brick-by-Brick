extends Node

# Signals; When a change occurs, this is called. Helps with scalaility.
signal hp_changed(value)
signal currency_changed(value)
signal round_changed(current, total)
signal ammo_type_changed(name, icon)


# Match State & Starting Variables
var hp: int = 100
var currency: int = 0

var round_current: int = 1
var round_total: int = 40

var ammo_name: String = "Basic Ball"
var ammo_icon: Texture2D = preload("res://assets/spritesArt/ball/ball.png")

# Setup
func _ready():
	add_to_group("gamestats")


# HP Setter Function; update Hp & broadcast said new Hp. 
func set_hp(value: int):
	hp = value
	hp_changed.emit(hp)


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


# Ammo Type Function; Update ammo name & it's icon, then broadcast changes. 
func set_ammo_type(name: String, icon: Texture2D):
	ammo_name = name
	ammo_icon = icon
	ammo_type_changed.emit(ammo_name, ammo_icon)
