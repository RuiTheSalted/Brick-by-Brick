# res://maps/specialMaps/spiralLevel/scripts/spiral_spawner.gd
# Handles wave spawning for the spiral level
# Bricks spawn at the outside edge of the spiral and travel inward toward the tennis court
# start_spawner() is called by spiral_level.gd after the path is guaranteed to be generated
extends Node

# Assign these in the Inspector
@export var brick_scene: PackedScene
@export var unbreakable_brick_scene: PackedScene

# Wave tuning - adjust in Inspector
@export var bricks_per_wave := 12          # How many bricks spawn per wave
@export var time_between_bricks := 0.6    # Seconds between each brick spawn
@export var time_between_waves := 2.5     # Seconds between waves

# Node references declared as variables so we can safely check them in _ready()
var path: Path2D = null
var wave_label: Label = null

var current_wave := 1
var bricks_alive := 0

func _ready() -> void:
	# When loaded inside levelWithUI SubViewport, relative paths don't work
	# Use get_parent() to find SpiralPath relative to spawner's parent
	var parent = get_parent()
	path = parent.get_node_or_null("SpiralPath")
	wave_label = parent.get_node_or_null("CanvasLayer/WaveLabel")

	if path == null:
		push_error("SpiralSpawner: Could not find SpiralPath")
		return
	if wave_label == null:
		push_error("SpiralSpawner: Could not find WaveLabel")
		return
	if brick_scene == null:
		push_error("SpiralSpawner: brick_scene not assigned in Inspector")
		return

# Called by spiral_level.gd after path is generated
# DO NOT rename this - spiral_level.gd calls it directly
func start_spawner() -> void:
	randomize()
	# Show wave 1 text then start spawning
	await show_wave_text(current_wave)
	start_wave()

func spawn_brick() -> void:
	# Create a new PathFollow2D to move the brick along the spiral
	var path_follow = PathFollow2D.new()
	path_follow.loop = false          # Brick should not loop back around
	path_follow.progress_ratio = 0.0  # Start at outside edge
	path.add_child(path_follow)

	# Determine brick type based on current wave
	# Unbreakable bricks appear after wave 20
	# Lava bricks appear after wave 10
	var rand_val = randi() % 20
	var brick_type: int = 0  # 0 = Normal, 1 = Lava, 2 = Unbreakable
	if current_wave > 20 and rand_val == 0:
		brick_type = 2  # Unbreakable
	elif current_wave > 10 and rand_val < 4:
		brick_type = 1  # Lava

	# Pick the correct scene based on type
	var scene_to_use = brick_scene
	if brick_type == 2 and unbreakable_brick_scene:
		scene_to_use = unbreakable_brick_scene

	var brick = scene_to_use.instantiate()

	# Health tiers scale with wave number
	# Early waves have weaker bricks, later waves have stronger ones
	var min_tier := 0
	var max_tier := 0
	if current_wave <= 5:
		min_tier = 0
		max_tier = 1   # Red / Orange
	elif current_wave <= 10:
		min_tier = 1
		max_tier = 3   # Orange / Green
	elif current_wave <= 20:
		min_tier = 2
		max_tier = 4   # Yellow / Blue
	else:
		min_tier = 3
		max_tier = 5   # Green / Purple

	var tier := randi_range(min_tier, max_tier)
	match tier:
		0: brick.health = 3
		1: brick.health = 6
		2: brick.health = 9
		3: brick.health = 12
		4: brick.health = 15
		5: brick.health = 20

	brick.brick_type = brick_type
	brick._update_visuals()
	brick.died.connect(_on_brick_removed)

	# Speed increases slightly each wave to ramp up difficulty
	brick.speed = 60.0 + (current_wave * 3.0)

	path_follow.add_child(brick)
	bricks_alive += 1

func start_wave() -> void:
	bricks_alive = 0
	# Spawn bricks one at a time with a delay between each
	for i in range(bricks_per_wave):
		if GameStats.is_game_over:
			return
		spawn_brick()
		await get_tree().create_timer(time_between_bricks).timeout

func start_next_wave() -> void:
	if GameStats.is_game_over:
		return
	current_wave += 1
	# Update global round counter
	GameStats.next_round()
	await show_wave_text(current_wave)
	if GameStats.is_game_over:
		return
	start_wave()

func show_wave_text(wave_num: int) -> void:
	# Safety checks before showing label
	if GameStats.is_game_over or get_tree() == null:
		return
	if wave_label == null:
		return
	wave_label.text = "Wave " + str(wave_num)
	wave_label.visible = true
	await get_tree().create_timer(1.5).timeout
	if get_tree() != null:
		wave_label.visible = false

func _on_brick_removed() -> void:
	# Track how many bricks are still alive
	bricks_alive -= 1
	# When all bricks are cleared start the next wave
	if bricks_alive <= 0 and get_tree() != null:
		await get_tree().create_timer(time_between_waves).timeout
		start_next_wave()
