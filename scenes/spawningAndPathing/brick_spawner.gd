extends Node

@export var brick_scene: PackedScene
@export var unbreakable_brick_scene: PackedScene
@onready var path = $"../Path2D"
@export var bricks_per_wave := 10
@export var time_between_bricks := 0.75
@export var time_between_waves := 2.0
@onready var wave_label = $"../CanvasLayer/WaveLabel"
var current_wave := 1
var bricks_alive := 0

func spawn_brick():
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)

	path_follow.loop = false #IMPORTANT: prevent looping
	path_follow.progress_ratio = 0.0 #Start at beginning

	# Randomly assign brick type
	var rand_val = randi() % 20
	var is_unbreakable = rand_val == 7

	var brick_type: int = 0

	if current_wave > 24 and is_unbreakable:
		brick_type = 2
	elif current_wave > 14 and rand_val < 4:
		brick_type = 1

	# NOW choose scene based on FINAL type	
	var scene_to_use = brick_scene
	if brick_type == 2 and unbreakable_brick_scene:
		scene_to_use = unbreakable_brick_scene

	var brick = scene_to_use.instantiate()

	bricks_alive += 1
	var min_tier := 0
	var max_tier := 0
	
	#decide allowed tiers based on wave
	if current_wave <= 5:
		min_tier = 0 #Red
		max_tier = 1 #Yellow
	elif current_wave <= 10:
		min_tier = 1  #Orange
		max_tier = 3 #Green
	elif current_wave <= 15:
		min_tier = 2 #Yellow
		max_tier = 4 #Blue
	elif current_wave <= 20:
		min_tier = 3 #Green
		max_tier = 5 #Purple
	else :
		min_tier = 4 #Blue
		max_tier = 5 #Purple
	
	var tier := randi_range(min_tier, max_tier)
	
	match tier: 
		0: brick.health = 3
		1: brick.health = 6
		2: brick.health = 9
		3: brick.health = 12
		4: brick.health = 15
		5: brick.health = 20
		
	brick.died.connect(_on_brick_removed)


	brick.brick_type = brick_type 
	
	brick._update_visuals()

	path_follow.add_child(brick)
	
	
func start_wave():
	bricks_alive = 0
	
	for i in range(bricks_per_wave):
		if GameStats.is_game_over:
			return
			
		spawn_brick()
		await get_tree().create_timer(time_between_bricks).timeout
		
		if GameStats == null or GameStats.is_game_over:
			return

func start_next_wave():
	if GameStats.is_game_over:
		return
	current_wave += 1
	
	await show_wave_text(current_wave)
	
	if GameStats.is_game_over:
		return

	start_wave()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	await show_wave_text(current_wave)
	start_wave()

func show_wave_text(wave_num):
	if GameStats.is_game_over:
		return
		
	if get_tree() == null:
		return
		
	wave_label.text = "Wave " + str(wave_num)
	wave_label.visible = true
	
	await get_tree().create_timer(1.5).timeout
	
	if get_tree() == null:
		return
	
	wave_label.visible = false
	
func _on_brick_removed():
	bricks_alive -= 1
	
	if bricks_alive <= 0:
		await get_tree().create_timer(time_between_waves).timeout
		start_next_wave()	
