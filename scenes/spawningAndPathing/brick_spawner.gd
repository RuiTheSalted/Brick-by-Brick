extends Node

@export var brick_scene: PackedScene
@export var unbreakable_brick_scene: PackedScene
@onready var path = $"../Path2D"
@export var bricks_per_wave := 10
@export var time_between_bricks := 0.75
@export var time_between_waves := 2.0

func spawn_brick():
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)

	path_follow.loop = false #IMPORTANT: prevent looping
	path_follow.progress_ratio = 0.0 #Start at beginning

	# Randomly assign brick type
	var rand_val = randi() % 20
	var is_unbreakable = rand_val < 8 and rand_val >= 7 # 5% chance

	var scene_to_use = brick_scene
	if is_unbreakable and unbreakable_brick_scene:
		scene_to_use = unbreakable_brick_scene

	var brick = scene_to_use.instantiate()

	if rand_val < 4:
		brick.brick_type = brick.BrickType.Lava       # 20% chance
	elif rand_val < 7:
		brick.brick_type = brick.BrickType.Strong      # 15% chance
	elif is_unbreakable:
		brick.brick_type = brick.BrickType.Unbreakable # 5% chance
	# else: Normal (60% chance)

	path_follow.add_child(brick)
	
	
func start_wave():
	for i in bricks_per_wave:
		spawn_brick()
		await get_tree().create_timer(time_between_bricks).timeout
		
	await get_tree().create_timer(time_between_waves).timeout
	start_wave()
	
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	start_wave()
