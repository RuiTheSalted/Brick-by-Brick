extends Node

@export var brick_scene: PackedScene
@onready var path = $"../Path2D"
@export var bricks_per_wave := 10
@export var time_between_bricks := 0.75
@export var time_between_waves := 2.0
 
func spawn_brick():
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	
	path_follow.loop = false #IMPORTANT: prevent looping
	path_follow.progress_ratio = 0.0 #Start at beginning
	
	var brick = brick_scene.instantiate()
	
	# spawns Lava bricks
	if randi() % 5 == 0:
		brick.brick_type = brick.BrickType.Lava
	
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
