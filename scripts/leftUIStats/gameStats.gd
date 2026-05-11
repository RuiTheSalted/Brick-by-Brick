extends Node

# Signals; When a change occurs, this is called. Helps with scalaility.
signal hp_changed(value)
signal currency_changed(value)
signal round_changed(current, total)
signal ammo_type_changed(name, icon)

var selected_music: AudioStream = null

var is_game_over: bool = false
var info_target_ball: String = ""

var ability_active: bool = false
var ability_timer: float = 0.0
var ability_duration: float = 0.0

var ability_cooldown: float = 0.0
var ability_cooldown_timer: float = 0.0

var buildup_duration: float = 10.0
var buildup_per_bounce: int = 1

var knockback_hits_remaining: int = 0

var tube_original_fire_rate: float = 0.0

var placing_hellfire: bool = false

var ability_name: String = ""

var current_map: String = ""

const LAVA_SCENE = preload("res://scenes/lavaTile/lavaTile.tscn")

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
		"damage": 2,
		"bounces": 5,
		"speed": 800.0, 
		"size": 1.0, 
		"shootSpeed": 1.0,
		"freezeDuration": 2.0,
		"freezeStrength": 4,
		"freezeRadius": 0.0,
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
		"speed": 500.0,
		"size": 2.0,
		"shootSpeed": 3.0
	},
	"Tennis Ball": {
		"scene": preload("res://scenes/ballsCollision/tennisBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/tennisBall.png"),
		"price": 715,
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
				"stats": {"shootSpeed": 0.2, "damage": 3, "bounces": 6}
			},
		],
		"path3": [
			{
				"name": "Bouncy Ball", 
				"desc": "Blue strip allows for more durable materials, allowing for more total bounces.", 
				"cost": 650, 
				"reset_cost": 78,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-1.png"), 
				"stats": {"bounces": 7}
			},
			{
				"name": "Efficient Ball", 
				"desc": "More efficient materials fill the blue strip, allowing for faster speeds and more bounces.", 
				"cost": 1950, 
				"reset_cost": 312,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-2.png"), 
				"stats": {"bounces": 12, "speed": 950.0}
			},
			{
				"name": "Basic Ball Z", 
				"desc": "Blue coated Basic Ball bounces several more times and is much faster allowing for damage build-up upon bounces.", 
				"cost": 3675, 
				"reset_cost": 750,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/basicBall/Basic Ball 3-3.png"), 
				"stats": {"bounces": 16, "speed": 1150.0, "ability": "buildup", "buildup_duration": 10.0, "buildup_per_bounce": 1}
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
				"stats": {"freezeDuration": 3.0, "shootSpeed": 1.2}
			},
			{
				"name": "Icicles",
				"desc": "Spreading cracks allow for even more freezing duration while making bricks more fragile. Shoot speed is reverted.",
				"cost": 3000,
				"reset_cost": 470,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-2.png"),
				"stats": {"freezeDuration": 4.5, "damage": 3, "shootSpeed": 1.0, "frozenDamageBonus": true}
			},
			{
				"name": "Sea Sickness",
				"desc": "Bricks stay in frozen state indefinitely.",
				"cost": 5250,
				"reset_cost": 1100,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 1-3.png"),
				"stats": {"freezeDuration": -1, "damage": 4, "shootSpeed": 0.9, "frozenBonusDamage": true}
			},
		],
		"path2": [
			{
				"name": "Extra Chilly",
				"desc": "Small ice particles increase freeze duration slightly.",
				"cost": 720,
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
				"stats": {"freezeDuration": 3.2, "freezeStrength": 6.5} 
			},
			{
				"name": "Absolute Zero",
				"desc": "Maximizes freeze strength and further increases freeze duration.",
				"cost": 4850,
				"reset_cost": 940,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/Iceball 2-3.png"),
				"stats": {"freezeDuration": 3.7, "freezeStrength": 10, "damage": 3}
			},
		],
		"path3": [
			{
				"name": "Group Freezing",
				"desc": "Increases the radius of the freeze effect.",
				"cost": 1000,
				"reset_cost": 120,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/animatedSprites/iceball 3-1.tres"),
				"stats": {"freezeRadius": 50.0}
			},
			{
				"name": "Snowstorm",
				"desc": "Further increases freeze radius and adds more freeze duration.",
				"cost": 2430,
				"reset_cost": 410,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/animatedSprites/iceball 3-2.tres"),
				"stats": {"freezeRadius": 125.0, "freezeDuration": 2.6} # this has to be made and likely slowDuration.
			},
			{
				"name": "Arctic Winds",
				"desc": "Ice rays maximiz freeze radius, and unlocks a special mapwide ability.",
				"cost": 4220,
				"reset_cost": 920,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/iceBall/animatedSprites/iceball 3-3.tres"),
				"stats": {"freezeRadius": 185.0, "freezeDuration": 2.9, "ability": "arctic_winds"}
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
				"stats": {"speed": 600.0}
			},
			{
				"name": "Bigger and Better",
				"desc": "Inner gold fillings on a bigger ball allow for more bounces, further speed increases and slight damage increases.",
				"cost": 1200,
				"reset_cost": 180,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-2.png"),
				"stats": {"speed": 650.0, "size": 2.25, "bounces": 19, "damage": 2}
			},
			{
				"name": "Embrace the Beach",
				"desc": "Fine materials further enhance ball speed, bounce capabilities, and damage..given a little size increase.",
				"cost": 2210,
				"reset_cost": 432,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 1-3.png"),
				"stats": {"speed": 750.0, "size": 2.75, "bounces": 23, "damage": 3}
			},
		],
		"path2": [
			{
				"name": "Resistant Plastic",
				"desc": "Beach Ball gains resistance to lava bricks.",
				"cost": 500,
				"reset_cost": 60,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-1.png"),
				"stats": {"lavaResist": true}
			},
			{
				"name": "Diamond Affinity",
				"desc": "Earns more currency upon hits and can fly further.",
				"cost": 1200,
				"reset_cost": 205,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-2.png"),
				"stats": {"lavaResist": true, "diamondAffinity": 8, "speed": 600}
			},
			{
				"name": "Royal Weakness",
				"desc": "Hit bricks get cursed and take double damage. Beach Ball gains a small damage and currency buff.",
				"cost": 2200,
				"reset_cost": 470,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball 2-3.png"),
				"stats": {"lavaResist": true, "diamondAffinity": 13, "royalWeakness": true, "speed": 650, "damage": 2} #cashPerHit and brickWeakening will need to be made
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
				"desc": "Metal materials greatly increases damage, with slight speed and size optimizations.",
				"cost": 1800,
				"reset_cost": 300,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-2.png"),
				"stats": {"size": 2.35, "damage": 4, "speed": 530}
			},
			{
				"name": "Metal Beach Ball",
				"desc": "More metal, more damage, more optimazing. Gains the ability to knockback 6 bricks.",
				"cost": 2650,
				"reset_cost": 620,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/beachBall/Beach Ball  3-3.png"),
				"stats": {"size": 2.50, "speed": 570, "ability": "knockbackBall", "knockback_hits": 15, "knockback_force": 400}
			},
		]
	},
	"Tennis Ball": {
		"path1": [
			{
				"name": "Athletics Pro",
				"desc": "These colors mimic a type of roadrunners, increasing speed, bounces, and damage.",
				"cost": 2100,
				"reset_cost": 250,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-1.png"),
				"stats": {"speed": 1500.0, "bounces": 9, "damage": 2}
			},
			{
				"name": "PROfessor",
				"desc": "Could've been D1, but settled for more speed and bounces.",
				"cost": 3600,
				"reset_cost": 680,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-2.png"),
				"stats": {"speed": 1800.0, "bounces": 12, "damage": 3}
			},
			{
				"name": "The Big J",
				"desc": "Too big to fail. Greatly increased stats across the board.",
				"cost": 5000,
				"reset_cost": 1300,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 1-3.png"),
				"stats": {"speed": 1900.0, "bounces": 15, "damage": 5}
			},
		],
		"path2": [
			{
				"name": "Pink Penn",
				"desc": "Pink Tennis Balls are easier to shoot.",
				"cost": 1000,
				"reset_cost": 120,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-1.png"),
				"stats": {"shootSpeed": 0.527}
			},
			{
				"name": "Ultra-Blue",
				"desc": "More professional balls are bouncier and less tough on the cannon.",
				"cost": 1895,
				"reset_cost": 350,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-2.png"),
				"stats": {"shootSpeed": 0.407, "bounces": 9}
			},
			{
				"name": "Pro-Penn",
				"desc": "Pro balls bounce more, are more powerful, and shoot slightly quicker.",
				"cost": 2730,
				"reset_cost": 640,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 2-3.png"),
				"stats": {"shootSpeed": 0.385, "bounces": 12, "damage": 2}
			},
		],
		"path3": [
			{
				"name": "Careful Hands",
				"desc": "Lighter green balls bounce more.",
				"cost": 700,
				"reset_cost": 80,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-1.png"),
				"stats": {"bounces": 9}
			},
			{
				"name": "Tennis Artistry",
				"desc": "White bonds help balls bounce more and faster.",
				"cost": 1600,
				"reset_cost": 220,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-2.png"),
				"stats": {"bounces": 13, "speed": 1550.0}
			},
			{
				"name": "Tube of Balls",
				"desc": "Industry standard balls bounce even more, and shoot out faster. Gains Tube of Balls ability.",
				"cost": 2750,
				"reset_cost": 550,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/tennisBall/Tennis Ball 3-3.png"),
				"stats": {"bounces": 18, "shootSpeed": 0.5, "speed": 1600.0, "ability": "tubeOfBalls", "tube_duration": 5.0, "tube_fire_rate": 0.1}
			},
		]
	},
	"Cannon Ball": {
		"path1": [
			{
				"name": "Grape Shot",
				"desc": "Shoots two extra projectiles while slightly decreasing damage. Balls are smaller, faster, and easier to fire.",
				"cost": 1200,
				"reset_cost": 140,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-1.png"),
				"stats": {"damage": 3, "shootSpeed": 1.75, "projectiles": 3, "size": 1, "speed": 750, "keep_base_texture": true}
			},
			{
				"name": "Case of Grapes",
				"desc": "Shoots four extra projectiles and restores original damage. Balls are smaller and faster.",
				"cost": 2400,
				"reset_cost": 430,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-2.png"),
				"stats": {"damage": 4, "shootSpeed": 1.65, "projectiles": 5, "size": 0.8, "speed": 900, "keep_base_texture": true}
			},
			{
				"name": "Basket of Grapes",
				"desc": "Shoots six extra projectiles out. Gains a small buff to all stats. Balls are even smaller.",
				"cost": 3600,
				"reset_cost": 1010,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 2-3.png"),
				"stats": {"damage": 6, "shootSpeed": 1.5, "projectiles": 7, "size": 0.6, "speed": 1000, "keep_base_texture": true}
			},
		],
		"path2": [
			{
				"name": "Barshot",
				"desc": "Converts cannon balls into barshot, doubling the impact damage.",
				"cost": 1500,
				"reset_cost": 180,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-1.png"),
				"stats": {"damage": 8}
			},
			{
				"name": "Chain Shot",
				"desc": "Converts barshot into chain shot, allowing for slightly more nimble balls and increases damage further.",
				"cost": 2800,
				"reset_cost": 520,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-2.png"),
				"stats": {"damage": 11}
			},
			{
				"name": "Shell Balls",
				"desc": "Both cannon balls become shell balls, allowing for shrapnel. Damage increases slightly.",
				"cost": 4100,
				"reset_cost": 1010,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 3-3.png"),
				"stats": {"damage": 14, "shrapnel": true}
			},
		],
		"path3": [
			{
				"name": "Hot Shots",
				"desc": "Cannon Balls are converted to lit cannon balls.",
				"cost": 1200,
				"reset_cost": 140,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-1.png"),
				"stats": {"burnEffect": true, "burn_damage": 1, "burn_duration": 3.0}
			},
			{
				"name": "Blazing Balls",
				"desc": "Lit balls are so hot that hit bricks spread the flame. Gains small fire rate buff.",
				"cost": 2900,
				"reset_cost": 500,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-2.png"),
				"stats": {"burnEffect": true, "fireSpreadEffect": true, "speed": 750, "shootSpeed": 1.7, "burn_damage": 1, "burn_duration": 5.0, "fire_spread_radius": 120}
			},
			{
				"name": "Hellfire",
				"desc": "Gains ability to leave lava on the track.",
				"cost": 4000,
				"reset_cost": 970,
				"icon": preload("res://assets/spritesArt/upgradeBallArt/cannonBall/Cannon Ball 1-3.png"),
				"stats": {"burnEffect": true, "fireSpreadEffect": true, "ability": "hellFire", "speed": 825, "shootSpeed": 1.55, "burn_damage": 3, "burn_duration": 3.0, "fire_spread_radius": 200} 
			},
		],
	}
}


# WHICH AMMO ARE OWNED (start with basic ball always)
var owned_ammo := {
	"Basic Ball": true
}


var current_stats := {}

# Match State & Starting Variables
var hp: int = 100
var currency: int = 20000

var round_current: int = 1
var round_total: int = 40

# Stores which inner map to load - set by map selection screen
var selected_map: String = ""

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


func _process(delta): 
	# Handle active ability duration
	if ability_active:
		ability_timer -= delta
		if ability_timer <= 0:
			ability_active = false
			# Restore shoot speed if tube ability
			if ability_name == "tubeOfBalls":
				ammo_data[ammo_name]["shootSpeed"] = tube_original_fire_rate
				# FORCE UPDATE
				ammo_type_changed.emit(ammo_name, ammo_icon)

	# Handle cooldown
	if ability_cooldown_timer > 0:
		ability_cooldown_timer -= delta
		if ability_cooldown_timer < 0:
			ability_cooldown_timer = 0

		# SAVE back to current ball
		ammo_data[ammo_name]["ability_cooldown_timer"] = ability_cooldown_timer


func activate_ability():
	if ability_cooldown_timer > 0:
		print("ON COOLDOWN")
		return

	print("ABILITY ACTIVATED:", ability_name)

	match ability_name:
		"buildup":
			ability_active = true
			ability_duration = buildup_duration
			ability_timer = ability_duration

			ability_cooldown = 30.0
			ability_cooldown_timer = ability_cooldown
			ammo_data[ammo_name]["ability_cooldown_timer"] = ability_cooldown_timer
			# APPLY TO ALL CURRENT BALLS
			for ball in get_tree().get_nodes_in_group("ball"):
				ball.buildup_active = true
		"arctic_winds":
			ability_active = true
			ability_duration = 0.1
			ability_timer = ability_duration
			ability_cooldown = 42
			ability_cooldown_timer = ability_cooldown
			ammo_data[ammo_name]["ability_cooldown_timer"] = ability_cooldown_timer

			var duration = 6.0
			var strength = ammo_data[ammo_name].get("freezeStrength", 3)

			# ❄️ FREEZE ALL BRICKS
			for brick in get_tree().get_nodes_in_group("bricks"):
				if not is_instance_valid(brick):
					continue
				if brick.has_method("apply_slow"):
					brick.apply_slow(duration, strength)
		"knockbackBall":
			ability_active = true
			ability_duration = 0.1  # not time-based, hit-based
			ability_timer = ability_duration

			ability_cooldown = 30.0
			ability_cooldown_timer = ability_cooldown
			ammo_data[ammo_name]["ability_cooldown_timer"] = ability_cooldown_timer

			# Allow 15 knockbacks
			knockback_hits_remaining = ammo_data[ammo_name].get("knockback_hits", 15)

		"tubeOfBalls":
			ability_active = true
			ability_duration = ammo_data[ammo_name].get("tube_duration", 5.0)
			ability_timer = ability_duration

			ability_cooldown = 35.0
			ability_cooldown_timer = ability_cooldown
			ammo_data[ammo_name]["ability_cooldown_timer"] = ability_cooldown_timer

			# Save original shoot speed
			tube_original_fire_rate = ammo_data[ammo_name]["shootSpeed"]

			# Apply rapid fire
			ammo_data[ammo_name]["shootSpeed"] = ammo_data[ammo_name].get("tube_fire_rate", 0.2)
			
		"hellFire":
			placing_hellfire = true
			print("Hellfire placement mode ON")

	ammo_type_changed.emit(ammo_name, ammo_icon)


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

	if s.has("ability"):
		ammo_data[ball_name]["ability"] = s["ability"]
		# APPLY IMMEDIATELY if this is the equipped ball
		if ball_name == ammo_name:
			ability_name = s["ability"]

	if s.has("buildup_duration"):
		ammo_data[ball_name]["buildup_duration"] = s["buildup_duration"]
		if ball_name == ammo_name:
			buildup_duration = s["buildup_duration"]
	if s.has("buildup_per_bounce"):
		ammo_data[ball_name]["buildup_per_bounce"] = s["buildup_per_bounce"]
		if ball_name == ammo_name:
			buildup_per_bounce = s["buildup_per_bounce"]

	if s.has("lavaResist"):
		ammo_data[ball_name]["lavaResist"] = s["lavaResist"]
	if s.has("frozenDamageBonus"):
		ammo_data[ball_name]["frozenDamageBonus"] = s["frozenDamageBonus"]
	if s.has("freezeStrength"):
		ammo_data[ball_name]["freezeStrength"] = s["freezeStrength"]
	if s.has("freezeDuration"):
		ammo_data[ball_name]["freezeDuration"] = s["freezeDuration"]
	if s.has("freezeRadius"):
		ammo_data[ball_name]["freezeRadius"] = s["freezeRadius"]

	if s.has("diamondAffinity"):
		ammo_data[ball_name]["diamondAffinity"] = s["diamondAffinity"]
	if s.has("royalWeakness"):
		ammo_data[ball_name]["royalWeakness"] = s["royalWeakness"]

	if s.has("knockback_hits"):
		ammo_data[ball_name]["knockback_hits"] = s["knockback_hits"]
	if s.has("knockback_force"):
		ammo_data[ball_name]["knockback_force"] = s["knockback_force"]

	if s.has("tube_duration"):
		ammo_data[ball_name]["tube_duration"] = s["tube_duration"]
	if s.has("tube_fire_rate"):
		ammo_data[ball_name]["tube_fire_rate"] = s["tube_fire_rate"]

	if s.has("projectiles"):
		ammo_data[ball_name]["projectiles"] = s["projectiles"]
	if s.has("keep_base_texture"):
		ammo_data[ball_name]["keep_base_texture"] = s["keep_base_texture"]

	if s.has("shrapnel"):
		ammo_data[ball_name]["shrapnel"] = s["shrapnel"]


	if s.has("burnEffect"):
		ammo_data[ball_name]["burnEffect"] = s["burnEffect"]
	if s.has("burn_damage"):
		ammo_data[ball_name]["burn_damage"] = s["burn_damage"]
	if s.has("burn_duration"):
		ammo_data[ball_name]["burn_duration"] = s["burn_duration"]
	if s.has("fireSpreadEffect"):
		ammo_data[ball_name]["fireSpreadEffect"] = s["fireSpreadEffect"]
	if s.has("fire_spread_radius"):
		ammo_data[ball_name]["fire_spread_radius"] = s["fire_spread_radius"]


	# Store future stats for later systems
	if s.has("hellFireAbility"):
		ammo_data[ball_name]["hellFireAbility"] = s["hellFireAbility"]

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
		"Ice Ball":    {"damage": 2, "bounces": 5, "speed": 800.0, "size": 1.0, "shootSpeed": 1.0, "freezeDuration": 2.0, "freezeStrength": 4, "freezeRadius": 0.0, "lavaResist": true, "slowEffect": true},
		"Cannon Ball": {"damage": 4, "bounces": 1, "speed": 600.0, "size": 1.25, "shootSpeed": 2.0},
		"Beach Ball":  {"damage": 1, "bounces": 15, "speed": 500.0, "size": 2.0, "shootSpeed": 3.0},
		"Tennis Ball": {"damage": 1, "bounces": 7, "speed": 1200.0, "size": 0.5, "shootSpeed": 0.667},
	}



	if base.has(ball_name):
		for stat_key in base[ball_name].keys():
			ammo_data[ball_name][stat_key] = base[ball_name][stat_key]

	# Clear upgrade icon so ball goes back to base texture
	ammo_data[ball_name].erase("currentIcon")

# Clear ability state if this ball had one
	if ball_name == ammo_name:
		ability_name = ""
		ability_active = false
		ability_timer = 0.0
		ability_cooldown_timer = 0.0
		buildup_duration = 10.0
		buildup_per_bounce = 1

	# Restore base icon on ammo_icon so UI and cannon reflect reset
	ammo_icon = ammo_data[ball_name]["icon"]

	# Apply to any currently active balls in the scene
	for ball in get_tree().get_nodes_in_group("ball"):
		ball.buildup_active = false
		ball.buildup_bonus = 0
		ball.buildup_per_bounce = 1

# Emit so cannon picks up restored shoot speed and icon
	ammo_type_changed.emit(ammo_name, ammo_icon)
	
	ammo_data[ball_name].erase("ability")
	ammo_data[ball_name].erase("buildup_duration")
	ammo_data[ball_name].erase("buildup_per_bounce")
	ammo_data[ball_name].erase("projectiles")
	ammo_data[ball_name].erase("keep_base_texture")
	ammo_data[ball_name].erase("shrapnel")
	ammo_data[ball_name].erase("shrapnel_count")
	ammo_data[ball_name].erase("shrapnel_damage")
	ammo_data[ball_name].erase("knockback_hits")
	ammo_data[ball_name].erase("knockback_force")
	ammo_data[ball_name].erase("burnEffect")
	ammo_data[ball_name].erase("burn_damage")
	ammo_data[ball_name].erase("burn_duration")
	ammo_data[ball_name].erase("fireSpreadEffect")
	ammo_data[ball_name].erase("fire_spread_radius")

	return true


func restart_game():
	reset_game()
	get_tree().paused = false
	selected_map = current_map
	get_tree().change_scene_to_file("res://scenes/levelWithUI/levelWithUi.tscn")

func reset_game():
	hp = 100
	currency = 20000
	round_current = 1

	ability_active = false
	ability_timer = 0.0
	ability_cooldown_timer = 0.0
	ability_name = ""

	chosen_paths.clear()
	purchased_tiers.clear()

	# RESET OWNED AMMO
	owned_ammo.clear()
	owned_ammo["Basic Ball"] = true

	# RESET AMMO DATA COMPLETELY
	ammo_data = {
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
		"damage": 2,
		"bounces": 5,
		"speed": 800.0, 
		"size": 1.0, 
		"shootSpeed": 1.0,
		"freezeDuration": 2.0,
		"freezeStrength": 4,
		"freezeRadius": 0.0,
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
		"speed": 500.0,
		"size": 2.0,
		"shootSpeed": 3.0
	},
	"Tennis Ball": {
		"scene": preload("res://scenes/ballsCollision/tennisBallCollision.tscn"),
		"icon": preload("res://assets/spritesArt/ball/tennisBall.png"),
		"price": 715,
		"damage": 1,
		"bounces": 7,
		"speed": 1200.0, 
		"size": 0.5,
		"shootSpeed": 0.667
	}
	}

	# RESET CURRENT BALL
	ammo_name = "Basic Ball"
	ammo_icon = ammo_data["Basic Ball"]["icon"]
	ammo_scene = ammo_data["Basic Ball"]["scene"]

	is_game_over = false

	hp_changed.emit(hp)
	currency_changed.emit(currency)
	ammo_type_changed.emit(ammo_name, ammo_icon)
	
	for ball in ammo_data.keys():
		if ammo_data[ball].has("currentIcon"):
			ammo_data[ball].erase("currentIcon")


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

	# RESET ONLY ACTIVE STATE (not cooldown)
	ability_active = false
	ability_timer = 0.0

	# LOAD ability for THIS ball only
	if ammo_data[ammo_name_str].has("ability"):
		ability_name = ammo_data[ammo_name_str]["ability"]
	else:
		ability_name = ""

	# 🔥 LOAD cooldown from this ball
	ability_cooldown_timer = ammo_data[ammo_name_str].get("ability_cooldown_timer", 0.0)

	# Load buildup values if they exist
	if ammo_data[ammo_name_str].has("buildup_duration"):
		buildup_duration = ammo_data[ammo_name_str]["buildup_duration"]
	else:
		buildup_duration = 10.0

	if ammo_data[ammo_name_str].has("buildup_per_bounce"):
		buildup_per_bounce = ammo_data[ammo_name_str]["buildup_per_bounce"]
	else:
		buildup_per_bounce = 1

	ammo_type_changed.emit(ammo_name, ammo_icon)


# Reset all match state for a fresh level start
func reset_for_new_level() -> void:
	hp = 100
	is_game_over = false
	round_current = 1
	hp_changed.emit(hp)
	round_changed.emit(round_current, round_total)


func _spawn_hellfire(pos: Vector2):
	print("SPAWNING LAVA AT:", pos)
	var lava = LAVA_SCENE.instantiate()
	# Find the level viewport and add lava there
	var level = get_tree().get_nodes_in_group("bricks")
	if level.size() > 0:
		var parent = level[0].get_parent()
		while parent != null and not parent is SubViewport:
			parent = parent.get_parent()
		if parent:
			lava.global_position = pos
			parent.add_child(lava)
			return
	# Fallback
	get_tree().get_root().add_child(lava)
	lava.global_position = pos
