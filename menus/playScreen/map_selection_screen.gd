extends Control

# VARIABLES FOR ARROWS
@onready var left_arrow: TextureButton = $background/margin/main/mapArea/leftArrow
@onready var right_arrow: TextureButton = $background/margin/main/mapArea/rightArrow
@onready var back_button: TextureButton = $background/margin/main/topBar/exitButton
@onready var easy_button: TextureButton = $background/margin/main/difficultyRow/difficultyButtons/easyMaps
@onready var medium_button: TextureButton = $background/margin/main/difficultyRow/difficultyButtons/normalMaps
@onready var hard_button: TextureButton = $background/margin/main/difficultyRow/difficultyButtons/hardMaps
@onready var special_button: TextureButton = $background/margin/main/difficultyRow/difficultyButtons/specialMaps

# FORMATS 6 MAPS PER SCREEN (dont update this)
@onready var tiles: Array[Control] = [
	$background/margin/main/mapArea/mapGrid/map1,
	$background/margin/main/mapArea/mapGrid/map2,
	$background/margin/main/mapArea/mapGrid/map3,
	$background/margin/main/mapArea/mapGrid/map4,
	$background/margin/main/mapArea/mapGrid/map5,
	$background/margin/main/mapArea/mapGrid/map6,
]

# REPLACE WITH "/map/mapNumber.png" & BOOLEAN NOT T/F. 
# MAPS GO HERE NOT IN NODE TREE, ADD THE MAPS HERE.
#{"preview": preload("res://assets/spritesArt/mapPreviewImgs/map1Thumbnail.png"), "completed": false, "scene": "res://scenes/levelWithUi.tscn"}
var maps := [
	{"preview": preload("res://assets/spritesArt/mapPreviewImgs/map1Thumbnail.png"), "completed": false, "scene": "res://scenes/levelWithUI/levelWithUi.tscn"},
	{"preview": preload("res://assets/spritesArt/bricks/placeholderBrick.png"), "completed": false, "scene": "res://scenes/levelWithUI/levelWithUi.tscn", "map": "res://maps/specialMaps/spiralLevel/scenes/spiral_level.tscn"},
	{"preview": preload("res://assets/spritesArt/bricks/placeholderBrick.png"), "completed": false},
	{"preview": preload("res://assets/spritesArt/bricks/placeholderBrick.png"), "completed": true},
	{"preview": preload("res://assets/spritesArt/bricks/placeholderBrick.png"), "completed": false},
	{"preview": preload("res://assets/spritesArt/bricks/placeholderBrick.png"), "completed": true},
	{"preview": preload("res://assets/spritesArt/bricks/placeholderBrick.png"), "completed": false},
	{"preview": preload("res://assets/spritesArt/bricks/placeholderBrick.png"), "completed": true},
]

# SET PAGE AND MAP INDEX
var page := 0 # WHICH GROUP OF 6
var selected_map_index := 0 # STORES CLICKED MAP

# RUN UPON LOADING
func _ready() -> void:
	# MAKE MAPS CLICKABLE (requires Mouse Filter = Stop on map1..mapN)
	for i in range(tiles.size()):
		tiles[i].gui_input.connect(func(event): _on_tile_gui_input(i, event))
		add_hover_to_tile(tiles[i]) #
	_refresh_page()
	add_hover_effect(left_arrow)
	add_hover_effect(right_arrow)
	add_hover_effect(back_button)
	add_hover_effect(easy_button)
	add_hover_effect(medium_button)
	add_hover_effect(hard_button)
	add_hover_effect(special_button)

# SEES HOW MANY PAGES WE HAVE
func _wrap_page(new_page: int) -> int:
	var max_page := int(ceil(float(maps.size()) / 6.0)) - 1
# IF THERE ARE NO MAPS, HANDLE THAT HERE
	if max_page < 0:
		return 0
# IF LEFT FROM START, OR RIGHT FROM END.
	return (new_page + (max_page + 1)) % (max_page + 1)

# REFRESH THE CURRENT PAGE
func _refresh_page() -> void:
	var start := page * 6 # 0*6 = 0, 1*6 = 6, etc...

# FOR EACH MAP DO THIS
	for i in range(6):
		var map_i := start + i # INDEX IN MAPS ARRAY
		var tile := tiles[i] # THE UI TILE SLOT

# IF MAP EXISTS FOR THIS SLOT, ADD PREVIEW IMG AND MEDAL
		if map_i < maps.size():
			tile.visible = true
			_apply_tile(tile, maps[map_i]["preview"], maps[map_i]["completed"])
# IF MAP DOESNT EXIST, SHOW TILE BUT WITH "coming soon".
		else:
			tile.visible = true
			_apply_tile_empty(tile)

# APPLY STUFF TO EMPTY MAPS
func _apply_tile_empty(tile: Control) -> void:
	var img: TextureRect = tile.get_node("card/mapImage") # MAP IMG
	var medal: TextureRect = tile.get_node("card/completionMedal") # MEDAL
	var soon: Control = tile.get_node("card/comingSoonContainer") # COMING SOON IMG

	img.texture = null # NO MAP IMG
	medal.visible = false # NO MEDAL
	soon.visible = true # YES COMING SOON

#APPLY STUFF TO EXISTING MAPS
func _apply_tile(tile: Control, preview: Texture2D, completed: bool) -> void:
	var img: TextureRect = tile.get_node("card/mapImage") # MAP IMG
	var medal: TextureRect = tile.get_node("card/completionMedal") # MEDAL
	var soon: Control = tile.get_node("card/comingSoonContainer") # COMING SOON IMG
	

	img.texture = preview # YES MAP IMG
	medal.visible = completed # YES MEDAL (will be a func eventually)
	soon.visible = false # NO COMING SOON (already exists)

# HANDLE CLICKING ON IMG, later we'll implement entering maps
func _on_tile_gui_input(tile_index: int, event: InputEvent) -> void:
# IF LEFT MOUSE CLICKED
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#Audio
		AudioManager.play_ui_click(1)
		selected_map_index = page * 6 + tile_index

		# IF ITS "coming soon" STOP HERE
		if selected_map_index >= maps.size():
			return

		print("Selected map:", selected_map_index)

		var map_data: Dictionary = maps[selected_map_index]

		# MAKE SURE SCENE PATH EXISTS
		if not map_data.has("scene") or String(map_data["scene"]).is_empty():
			print("Map has no scene assigned yet:", selected_map_index)
			return

		var scene_path: String = map_data["scene"]
		print("Loading map:", selected_map_index, "->", scene_path)
		
		# Store the inner map path in GameStats so levelWithUI can read it
		if map_data.has("map"):
			GameStats.selected_map = map_data["map"]
		else:
			GameStats.selected_map = ""
		#get_tree().change_scene_to_file("res://scenes/levelWithUI/levelWithUi.tscn")
		#get_tree().change_scene_to_file(scene_path)
		get_tree().change_scene_to_file(map_data["scene"])

# WHEN LEFT ARROW CLICKED, GO LEFT
func _on_left_arrow_pressed() -> void:
	# Audio 
	AudioManager.play_ui_click(0)
	page = _wrap_page(page - 1)
	_refresh_page()

# WHEN RIGHT ARROW CLICKED, GO RIGHT
func _on_right_arrow_pressed() -> void:
	AudioManager.play_ui_click(1)
	page = _wrap_page(page + 1)
	_refresh_page()

# WHEN EXIT CLICKED, GO TO TITLE SCREEN
func _on_exit_button_pressed() -> void:
	AudioManager.play_ui_click(3)
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")

func add_hover_effect(btn: BaseButton):
	btn.mouse_entered.connect(func():
		btn.modulate = Color(1.2, 1.2, 1.2, 1)
	)
	
	btn.mouse_exited.connect(func():
		btn.modulate = Color(1, 1, 1, 1)
	)

func add_hover_to_tile(tile: Control):
	tile.mouse_entered.connect(func():
		tile.modulate = Color(1.1, 1.1, 1.1, 1)
	)
	tile.mouse_exited.connect(func():
		tile.modulate = Color(1, 1, 1, 1)
)
