extends TextureButton

@export var ammo_name: String = "Tennis Ball"

@onready var price_label = $"tennisBallPrice"

var stats

var style_locked := StyleBoxFlat.new()
var style_owned := StyleBoxFlat.new()
var style_active := StyleBoxFlat.new()

func _ready():
	stats = get_tree().get_first_node_in_group("gamestats")

# LOCKED (Need Purchase) → FFE2B2
	style_locked.bg_color = Color("#FFE2B2")
	style_locked.corner_radius_top_left = 15
	style_locked.corner_radius_top_right = 15
	style_locked.corner_radius_bottom_left = 15
	style_locked.corner_radius_bottom_right = 15

# OWNED (Equip) → C0C0C0
	style_owned.bg_color = Color("#C0C0C0")
	style_owned.corner_radius_top_left = 15
	style_owned.corner_radius_top_right = 15
	style_owned.corner_radius_bottom_left = 15
	style_owned.corner_radius_bottom_right = 15

# ACTIVE (In Use) → 5ACFFF
	style_active.bg_color = Color("#5ACFFF")
	style_active.corner_radius_top_left = 15
	style_active.corner_radius_top_right = 15
	style_active.corner_radius_bottom_left = 15
	style_active.corner_radius_bottom_right = 15

	update_display()

	stats.currency_changed.connect(_on_stats_changed)
	stats.ammo_type_changed.connect(_on_stats_changed)

func _pressed():
	if not stats.owned_ammo.get(ammo_name, false):
		stats.buy_ammo(ammo_name)

	if stats.owned_ammo.get(ammo_name, false):
		stats.set_ammo_type(ammo_name)

	update_display()

func _on_stats_changed(_a = null, _b = null):
	update_display()

func update_display():
	if not stats:
		return

	var is_owned = stats.owned_ammo.get(ammo_name, false)
	var is_active = stats.ammo_name == ammo_name

	if not is_owned:
		price_label.text = "$" + str(stats.ammo_data[ammo_name]["price"])
		modulate = Color(0.6, 0.6, 0.6)  # dim button
		price_label.add_theme_stylebox_override("normal", style_locked)
		self.disabled = false  # still clickable to buy
	elif is_active:
		price_label.text = "In Use"
		modulate = Color(1, 1, 1)  # full brightness
		price_label.add_theme_stylebox_override("normal", style_active)
		self.disabled = false
	else:
		price_label.text = "Equip"
		modulate = Color(0.85, 0.85, 0.85)  # slight dim
		price_label.add_theme_stylebox_override("normal", style_owned)
		self.disabled = false
