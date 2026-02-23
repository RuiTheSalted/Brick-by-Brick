extends Control

# GRID THAT HOLDS ACHIEVEMENTS
@onready var grid = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/CenterContainer/GridContainer

# FOLDER WITH ALL ACHIEVEMENTS
@export var achievementFolder := "res://menus/achievementsScreen/achievementItems/"

# UPON LOADING ACHIEVEMENTS SCREEN, LOAD ACHIEVMENT FOLDER
func _ready() -> void:
	loadAchievements(achievementFolder)

# LOAD THE ACHIEVEMENTS ONTO SCREEN
func loadAchievements(folder_path: String) -> void:
	var dir: DirAccess = DirAccess.open(folder_path) #HOW GODOT OPENS FILES
	if dir == null: #IF DOESNT OPEN, PRINT ERROR AND STOP FUNC
		push_error("Could not open folder: " + folder_path)
		return

#START READING AND RETURN FIRST FILE
	dir.list_dir_begin()
	var file_name: String = dir.get_next()

#LOOP UNTIL NO MORE FILES
	while file_name != "":
		#ONLY THE .tscn FILES (ones we want)
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			#BUILD PATH -> FOLDER + FILE
			var scene_path: String = folder_path + file_name

#LOAD THE SCENE
			var packed := load(scene_path)
			#CONTINUE ONLY IF ITS A SCENE
			if packed is PackedScene:
				var scene: PackedScene = packed #blueprint
				var inst: Node = scene.instantiate() #real object now
				grid.add_child(inst) #added to grid

#NEXT FILE
		file_name = dir.get_next() 

#END
	dir.list_dir_end()

# WHEN EXIT CLICKED, LOAD TITLE SCREEN
func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")
