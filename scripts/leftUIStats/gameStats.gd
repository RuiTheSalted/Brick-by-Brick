extends Node

# Signals; When a change occurs, this is called. Helps with scalaility.
signal hp_changed(value)
signal currency_changed(value)
signal round_changed(current, total)
signal ammo_type_changed(name, icon)

var is_game_over: bool = false


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
			{
				"name": "Basic Ball +",
				"desc": "Added red strip gives the Basic Ball a harder impact.", 
				"cost": 550, 
				"reset_cost": 66,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 1-1.png"),
				"stats": {"damage": 2}
			},
			{
				"name": "Basic Ball ++", 
				"desc": "Added X improves impact, while red strip is repurposed into bouncing improvements.", 
				"cost": 1800, 
				"reset_cost": 282,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 1-2.png"),
				"stats": {"damage": 3, "bounces": 7}
			},
			{
				"name": "Basic Ball X", 
				"desc": "Red material coats the Basic Ball adding even more damage as well as making firing easier on the cannon.", 
				"cost": 4300, 
				"reset_cost": 800,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 1-3.png"),
				"stats": {"damage": 5, "bounces": 8, "shootSpeed": 0.4}
			},
		],
		"path2": [
			{
				"name": "Improved Materials", 
				"desc": "Green strip makes firing Basic Ball easier on the cannon.",
				"cost": 650, 
				"reset_cost": 78,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 2-1.png"),
				"stats": {"shootSpeed": 0.4}
			},
			{
				"name": "Optimized Ball", 
				"desc": "Further optimized Basic Balls allowing for harder impacts while also improving fire speed.", 
				"cost": 2000,
				"reset_cost": 318, 
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 2-2.png"),
				"stats": {"shootSpeed": 0.3, "damage": 2}
			},
			{
				"name": "Basic Ball Y", 
				"desc": "Green material coats the Basic Ball allowing for even faster firing, and better bounce capabilities.", 
				"cost": 4100, 
				"reset_cost": 810,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 2-3.png"),
				"stats": {"shootSpeed": 0.2, "damage": 3, "bounces": 7}
			},
		],
		"path3": [
			{
				"name": "Bouncy Ball", 
				"desc": "Blue strip allows for more durable materials, allowing for more total bounces.", 
				"cost": 650, 
				"reset_cost": 78,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-1.png"), 
				"stats": {"bounces": 8}
			},
			{
				"name": "Efficient Ball", 
				"desc": "More efficient materials fill the blue strip, allowing for faster speeds and more bounces.", 
				"cost": 1950, 
				"reset_cost": 312,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-2.png"), 
				"stats": {"bounces": 12, "speed": 900.0}
			},
			{
				"name": "Basic Ball Z", 
				"desc": "Blue coated Basic Ball bounces several more times and is much faster allowing for damage build-up upon bounces.", 
				"cost": 3675, 
				"reset_cost": 750,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-3.png"), 
				"stats": {"bounces": 18, "speed": 1000.0} #ability here
			},
		]
	},
	"Ice Ball": {
		"path1": [
			{
				"name": "Enchanced Freezing",
				"desc": "Cold spot increases allowing Ice Ball to freeze for longer at a reduced fire rate.",
				"cost": 900,
				"reset_cost": 110,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-1.png"),
				"stats": {"freezeDuration": 2.0, "shootSpeed": 1.2}
			},
			{
				"name": "Icicles",
				"desc": "Cracks from the cold spot allow for even more freezing duration while also making bricks more fragile. Shoot speed is reverted.",
				"cost": 3000,
				"reset_cost": 470,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-2.png"),
				"stats": {"freezeDuration": 3.5, "damage": 2, "shootSpeed": 1.0}
			},
			{
				"name": "Sea Sickness",
				"desc": "Bricks stay in frozen state indefinitely.",
				"cost": 5250,
				"reset_cost": 1100,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-3.png"),
				"stats": {"freezeDuration": -1, "damage": 3}
			},
		],
		"path2": [
			{
				"name": "Extra Chilly",
				"desc": "Small ice particles increase freeze duration slightly.",
				"cost": 920,
				"reset_cost": 110,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 2-1.png"),
				"stats": {"freezeDuration": 2.5}
			},
			{
				"name": "Deep Freeze",
				"desc": "Crystals form further increasing freeze duration and strengthens the freeze effect.",
				"cost": 2100,
				"reset_cost": 360,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 2-2.png"),
				"stats": {"freezeDuration": 3.0, "freezeStrength": 1} #this will be slowMultiplier likely
			},
			{
				"name": "Absolute Zero",
				"desc": "Maximizes freeze strength and further increases freeze duration.",
				"cost": 4850,
				"reset_cost": 940,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 2-3.png"),
				"stats": {"freezeDuration": 4.0, "freezeStrength": 3} #this will be slowMuliplier likely
			},
		],
		"path3": [
			{
				"name": "Group Freezing",
				"desc": "Increases the radius of the freeze effect.",
				"cost": 1000,
				"reset_cost": 120,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 3-1.png"),
				"stats": {"freezeRadius": 50.0} #this must be created
			},
			{
				"name": "Snowstorm",
				"desc": "Further increases freeze radius and adds more freeze duration.",
				"cost": 2430,
				"reset_cost": 410,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 3-2.png"),
				"stats": {"freezeRadius": 100.0, "freezeDuration": 2.25} # this has to be made and likely slowDuration.
			},
			{
				"name": "Arctic Winds",
				"desc": "Ice rays maximiz freeze radius, and unlocks a special mapwide ability.",
				"cost": 4220,
				"reset_cost": 920,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 3-3.png"),
				"stats": {"freezeRadius": 175.0, "freezeDuration": 2.0} # this has to be made and likely slowDuration.
			},
		]
	},
	"Beach Ball": {
		"path1": [
			{
				"name": "Weight Reduction",
				"desc": "Weak yellow coating, while ugly, lowers ball weight allowing for speed increases.",
				"cost": 300,
				"reset_cost": 40,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-1.png"),
				"stats": {"speed": 550.0}
			},
			{
				"name": "Bigger and Better",
				"desc": "Inner gold fillings on a bigger ball allow for more bounces.",
				"cost": 1200,
				"reset_cost": 180,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-2.png"),
				"stats": {"speed": 600.0, "size": 2.25, "bounces": 18}
			},
			{
				"name": "Embrace the Beach",
				"desc": "Fine materials further enhance ball speed and bounce capabilities, given a little size increase.",
				"cost": 2210,
				"reset_cost": 432,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-3.png"),
				"stats": {"speed": 750.0, "size": 2.75, "bounces": 22}
			},
		],
		"path2": [
			{
				"name": "Resistant Plastic",
				"desc": "Beach Ball gains resistance to lava bricks.",
				"cost": 1000,
				"reset_cost": 120,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-1.png"),
				"stats": {"laveResist": true}
			},
			{
				"name": "Diamond Affinity",
				"desc": "Earns more currency per hit.",
				"cost": 2000,
				"reset_cost": 360,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-2.png"),
				"stats": {"laveResist": true, "cashPerHit": 3} #cashPerHit will need to be made
			},
			{
				"name": "Royal Weakness",
				"desc": "Weakens bricks get cursed and take double damage. Beach Ball gains a small damage buff.",
				"cost": 3500,
				"reset_cost": 780,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-3.png"),
				"stats": {"laveResist": true, "cashPerHit": 5, "brickWeakening": true, "damage": 2} #cashPerHit and brickWeakening will need to be made
			},
		],
		"path3": [
			{
				"name": "Weight Lining",
				"desc": "A bigger ball lined with metal does slightly more damage.",
				"cost": 700,
				"reset_cost": 80,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-1.png"),
				"stats": {"size": 2.25, "damage": 2}
			},
			{
				"name": "Metal Plating",
				"desc": "Metal materials greatly increases damage.",
				"cost": 2300,
				"reset_cost": 360,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-2.png"),
				"stats": {"size": 2.25, "damage": 4}
			},
			{
				"name": "Metal Beach Ball",
				"desc": "More metal, more damage. Gains the ability to knockback 6 bricks.",
				"cost": 4500,
				"reset_cost": 900,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-3.png"),
				"stats": {"size": 2.25, "damage": 6, "knockbackAbility": true} #will need to add knockback ability.
			},
		]
	},
	"Tennis Ball": {
		"path1": [
			{
				"name": "Athletics Pro",
				"desc": "These colors mimic a type of roadrunners.",
				"cost": 2100,
				"reset_cost": 250,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-1.png"),
				"stats": {"speed": 1500.0, "bounces": 10, "damage": 3}
			},
			{
				"name": "PROfessor",
				"desc": "Could've been D1, but is a humble man.",
				"cost": 3600,
				"reset_cost": 680,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-2.png"),
				"stats": {"speed": 1800.0, "bounces": 13, "damage": 3}
			},
			{
				"name": "The Big J",
				"desc": "Too big to fail.",
				"cost": 5000,
				"reset_cost": 1300,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-3.png"),
				"stats": {"speed": 1800.0, "bounces": 15, "damage": 5}
			},
		],
		"path2": [
			{
				"name": "Pink Penn",
				"desc": "Pink Tennis Balls are easier to shoot.",
				"cost": 1000,
				"reset_cost": 120,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-1.png"),
				"stats": {"shootSpeed": 0.4}
			},
			{
				"name": "Ultra-Blue",
				"desc": "More professional balls are bouncier and less tough on the cannon.",
				"cost": 1895,
				"reset_cost": 350,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-2.png"),
				"stats": {"shootSpeed": 0.3, "bounces": 9}
			},
			{
				"name": "Pro-Penn",
				"desc": "Pro balls bounce more.",
				"cost": 2430,
				"reset_cost": 640,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-3.png"),
				"stats": {"shootSpeed": 0.3, "bounces": 12}
			},
		],
		"path3": [
			{
				"name": "Careful Hands",
				"desc": "Lighter green balls bounce more.",
				"cost": 700,
				"reset_cost": 80,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-1.png"),
				"stats": {"bounces": 8}
			},
			{
				"name": "Tennis Artistry",
				"desc": "White bonds help balls bounce more and faster.",
				"cost": 1100,
				"reset_cost": 220,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-2.png"),
				"stats": {"bounces": 9, "speed": 1350.0}
			},
			{
				"name": "Tube of Balls",
				"desc": "Industry standard ballls bounce even more, and shoot out faster. Gains Plethora of Balls ability.",
				"cost": 2750,
				"reset_cost": 550,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-3.png"),
				"stats": {"bounces": 18, "shootSpeed": 0.5, "speed": 1500.0}
			},
		]
	},
	"Cannon Ball": {
		"path1": [
			{
				"name": "Grape Shot",
				"desc": "Shoots two extra projectiles while slightly decreasing damage.",
				"cost": 1200,
				"reset_cost": 140,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-1.png"),
				"stats": {"damage": 3}
			},
			{
				"name": "Case of Grapes",
				"desc": "Shoots four extra projectiles and restores original damage.",
				"cost": 2400,
				"reset_cost": 430,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-2.png"),
				"stats": {"damage": 4}
			},
			{
				"name": "Basket of Grapes",
				"desc": "Shoots six extra projectiles out. Gains a small damage buff.",
				"cost": 4800,
				"reset_cost": 1010,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-3.png"),
				"stats": {"damage": 6}
			},
		],
		"path2": [
			{
				"name": "Barshot",
				"desc": "Converts cannon balls into barshot, doubling the impact.",
				"cost": 1500,
				"reset_cost": 180,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-1.png"),
				"stats": {"damage": 8}
			},
			{
				"name": "Chain Shot",
				"desc": "Converts barshot into chain shot, allowing for slightly more nimble balls, increasing damage further.",
				"cost": 2800,
				"reset_cost": 520,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-2.png"),
				"stats": {"damage": 11}
			},
			{
				"name": "Shell Balls",
				"desc": "Both cannon balls become shell balls. Damage increases slightly and shrapnel now dispenses.",
				"cost": 4100,
				"reset_cost": 1010,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-3.png"),
				"stats": {"damage": 13, "shrapnel": true} #will need to make shrapnel
			},
		],
		"path3": [
			{
				"name": "Hot Shots",
				"desc": "Cannon Balls are converted to lit cannon balls.",
				"cost": 1200,
				"reset_cost": 140,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-1.png"),
				"stats": {"fireCannonEffect": true} #this will have to be made
			},
			{
				"name": "Blazing Balls",
				"desc": "Lit balls are so hot that hit bricks spread the flame.",
				"cost": 2900,
				"reset_cost": 500,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-2.png"),
				"stats": {"fireCannonEffect": true, "fireSpreadEffect": true} #this will have to be made
			},
			{
				"name": "Hellfire",
				"desc": "Gains ability to leave lava on the track.",
				"cost": 4000,
				"reset_cost": 970,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-3.png"),
				"stats": {"fireCannonEffect": true, "fireSpreadEffect": true, "hellFireAbility": true} #this will have to be made
			},
		],
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

# Tracks which path is chosen per ball (null = none chosen)
var chosen_paths: Dictionary = {}

# Tracks highest tier purchased per ball (0 = none)
var purchased_tiers: Dictionary = {}

# Setup
func _ready():
	add_to_group("gamestats")


# HP Setter Function; update Hp & broadcast said new Hp. 
func set_hp(value: int):
	hp = value
	hp_changed.emit(hp)
	
	if hp <= 0 and not is_game_over:
		trigger_defeat()


# If Lose, Go GameOverScreen
func trigger_defeat():
	is_game_over = true
	get_tree().change_scene_to_file("res://menus/gameOverScreen/gameOverScreen.tscn")


# Currency Add Function; update currency & broadcast said new amount. 
func add_currency(amount: int):
	currency += amount
	currency_changed.emit(currency)


# Currency Spend Function; update currency & broadcast said new amount. 
func spend_currency(amount: int):
	currency -= amount
	currency_changed.emit(currency)


func purchase_upgrade(ball_name: String, path_key: String, tier: int):
	if not upgrade_data.has(ball_name):
		return
	
	var upgrade = upgrade_data[ball_name][path_key][tier]
	var cost = upgrade["cost"]
	
	if currency < cost:
		return
	
	# Deduct currency
	spend_currency(cost)
	
	# Lock in the chosen path for this ball
	chosen_paths[ball_name] = path_key
	
	# Mark highest purchased tier
	purchased_tiers[ball_name] = tier + 1
	
	# Apply stats if this is the currently equipped ball
	if ball_name == ammo_name:
		apply_upgrade_stats(ball_name, path_key, tier)


func apply_upgrade_stats(ball_name: String, path_key: String, tier: int):
	var upgrade = upgrade_data[ball_name][path_key][tier]
	
	if not upgrade.has("stats"):
		return
	
	var s = upgrade["stats"]
	
	# Apply stats that exist in current system
	if s.has("damage"):
		ammo_data[ball_name]["damage"] = s["damage"]
	if s.has("bounces"):
		ammo_data[ball_name]["bounces"] = s["bounces"]
	if s.has("speed"):
		ammo_data[ball_name]["speed"] = s["speed"]
	if s.has("size"):
		ammo_data[ball_name]["size"] = s["size"]
	if s.has("shootSpeed"):
		ammo_data[ball_name]["shootSpeed"] = s["shootSpeed"]
	
	# Store future stats for later systems
	if s.has("freezeDuration"):
		ammo_data[ball_name]["freezeDuration"] = s["freezeDuration"]
	if s.has("freezeStrength"):
		ammo_data[ball_name]["freezeStrength"] = s["freezeStrength"]
	if s.has("freezeRadius"):
		ammo_data[ball_name]["freezeRadius"] = s["freezeRadius"]
	if s.has("fireResistance"):
		ammo_data[ball_name]["fireResistance"] = s["fireResistance"]
	if s.has("cashPerHit"):
		ammo_data[ball_name]["cashPerHit"] = s["cashPerHit"]
	if s.has("brickWeakening"):
		ammo_data[ball_name]["brickWeakening"] = s["brickWeakening"]
	if s.has("fireDamage"):
		ammo_data[ball_name]["fireDamage"] = s["fireDamage"]
	if s.has("fireSpread"):
		ammo_data[ball_name]["fireSpread"] = s["fireSpread"]
	if s.has("projectileCount"):
		ammo_data[ball_name]["projectileCount"] = s["projectileCount"]
	if s.has("laveResist"):
		ammo_data[ball_name]["lavaResist"] = s["laveResist"]
	if s.has("knockbackAbility"):
		ammo_data[ball_name]["knockbackAbility"] = s["knockbackAbility"]
	if s.has("shrapnel"):
		ammo_data[ball_name]["shrapnel"] = s["shrapnel"]
	if s.has("fireCannonEffect"):
		ammo_data[ball_name]["fireCannonEffect"] = s["fireCannonEffect"]
	if s.has("fireSpreadEffect"):
		ammo_data[ball_name]["fireSpreadEffect"] = s["fireSpreadEffect"]
	if s.has("hellFireAbility"):
		ammo_data[ball_name]["hellFireAbility"] = s["hellFireAbility"]
	if s.has("brickWeakening"):
		ammo_data[ball_name]["brickWeakening"] = s["brickWeakening"]

	# Store the current upgrade icon so cannon can apply it to spawned balls
	ammo_data[ball_name]["currentIcon"] = upgrade_data[ball_name][path_key][tier]["icon"]

	# Emit signal so cannon picks up new shoot speed immediately
	ammo_type_changed.emit(ammo_name, ammo_icon)


# Next Round Function; Iterate round count & broadcast changes. 
func next_round():
	round_current += 1
	round_changed.emit(round_current, round_total)


# Reset Rounds Function; Start round at one & broadcast changees. 
func reset_round():
	round_current = 1
	round_changed.emit(round_current, round_total)


func reset_upgrades(ball_name: String) -> bool:
	# Check if there are any upgrades to reset
	if not chosen_paths.has(ball_name):
		return false

	var chosen_path = chosen_paths[ball_name]
	var purchased_tier = purchased_tiers.get(ball_name, 0)

	if purchased_tier == 0:
		return false

	# Get reset cost of highest purchased tier
	var last_upgrade = upgrade_data[ball_name][chosen_path][purchased_tier - 1]
	var reset_cost = last_upgrade.get("reset_cost", 0)

	# Check if player can afford reset fee
	if currency < reset_cost:
		return false

	# Charge the reset fee
	spend_currency(reset_cost)

	# Clear upgrade tracking for this ball
	chosen_paths.erase(ball_name)
	purchased_tiers.erase(ball_name)

	# Restore base stats from original values
	var base = {
		"Basic Ball":  {"damage": 1, "bounces": 5, "speed": 800.0, "size": 1.0, "shootSpeed": 0.5},
		"Ice Ball":    {"damage": 1, "bounces": 5, "speed": 800.0, "size": 1.0, "shootSpeed": 1.0},
		"Cannon Ball": {"damage": 4, "bounces": 1, "speed": 600.0, "size": 1.25, "shootSpeed": 2.0},
		"Beach Ball":  {"damage": 1, "bounces": 15, "speed": 400.0, "size": 2.0, "shootSpeed": 3.0},
		"Tennis Ball": {"damage": 1, "bounces": 7, "speed": 1200.0, "size": 0.5, "shootSpeed": 0.667},
	}

	if base.has(ball_name):
		for stat_key in base[ball_name].keys():
			ammo_data[ball_name][stat_key] = base[ball_name][stat_key]

	# Clear upgrade icon so ball goes back to base texture
	ammo_data[ball_name].erase("currentIcon")

	# Emit so cannon picks up restored shoot speed
	ammo_type_changed.emit(ammo_name, ammo_icon)

	return true


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
