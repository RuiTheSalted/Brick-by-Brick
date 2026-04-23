# level_with_ui.gd
# Attach this to the LevelWithUi root (Control).
# Purpose:
# Keep the SubViewport (or container’s internal viewport) sized to the center "gameFrame"
# Load a level scene into that viewport so your UI can live on the left/right without covering the map

extends Control

# Set this in the Inspector to whichever map/level scene you want to test.
@export var default_map_path: String = "res://scenes/regularLevels/level.tscn"

# Paths inside LevelWithUi.tscn (rename these constants if your node names differ)
const GAME_FRAME_PATH := "mainRow/centerMap/gameFrame"
const GAME_VIEWPORT_PATH := GAME_FRAME_PATH + "/gameViewport"

# Cache nodes (kept untyped on purpose to avoid "type not found in scope" issues)
@onready var game_frame = get_node_or_null(GAME_FRAME_PATH)
@onready var game_viewport_node = get_node_or_null(GAME_VIEWPORT_PATH)

# Tracks currently loaded level instance
var current_level_instance: Node = null
var current_level_path: String = ""


func _ready() -> void:
	# audio
	AudioManager.play_music(SoundBank.MUSIC_LEVEL_FOREST_1)
	# Basic safety checks
	if game_frame == null:
		push_error("LevelWithUi: Missing node at '%s' (your center frame)." % GAME_FRAME_PATH)
	if game_viewport_node == null:
		push_warning("LevelWithUi: Missing node at '%s' (will try to auto-find one)." % GAME_VIEWPORT_PATH)

	# Make sure viewport renders at the correct size before loading anything
	_update_viewport_size()

	# Auto-load a map so you can immediately test layout
	if default_map_path != "":
		load_map(default_map_path)


func _notification(what: int) -> void:
	# When the window/layout changes, keep the viewport matched to the frame
	if what == NOTIFICATION_RESIZED:
		_update_viewport_size()


# ---------------------------
# VIEWPORT FINDING + RESIZING
# ---------------------------

# Some Godot setups complain about referencing engine types directly.
# So instead of `child is ViewportContainer`, we use get_class() and capabilities.
func _class_is(node: Object, cls_name: String) -> bool:
	return node != null and node.get_class() == cls_name


func _update_viewport_size() -> void:
	# Can't size anything without the frame
	if game_frame == null:
		return

	# If we don't have the viewport node yet, attempt to find it under game_frame.
	# This supports either:
	# - SubViewport directly, OR
	# - SubViewportContainer / ViewportContainer, OR
	# - Viewport directly (less common)
	if game_viewport_node == null:
		for child in game_frame.get_children():
			var cls := child.get_class()
			if cls == "SubViewport" or cls == "Viewport" or cls == "SubViewportContainer" or cls == "ViewportContainer":
				game_viewport_node = child
				print("LevelWithUi: Found viewport node:", child.name, "(class:", cls, ")")
				break

	# Still nothing found? Nothing to resize
	if game_viewport_node == null:
		return

	# 1) If it is an actual viewport node, it should have a `size` property.
	if "size" in game_viewport_node:
		game_viewport_node.size = game_frame.size
		return

	# 2) If it is a container (ViewportContainer/SubViewportContainer), resize its internal viewport.
	if game_viewport_node.has_method("get_viewport"):
		var vp = game_viewport_node.get_viewport()
		if vp != null and "size" in vp:
			vp.size = game_frame.size
		else:
			push_warning("LevelWithUi: get_viewport() returned null (or viewport has no size).")
		return

	# 3) Final fallback for Control-like nodes
	if "rect_size" in game_viewport_node:
		game_viewport_node.rect_size = game_frame.size
		return


# ---------------------------
# LEVEL LOADING
# ---------------------------

# Loads a scene at `path` and places it into the viewport (or as a fallback, the frame).
func load_map(path: String) -> void:
	# Make sure the file exists
	if not FileAccess.file_exists(path):
		push_error("LevelWithUi.load_map: File not found: %s" % path)
		return

	# Load the scene
	var scene_res = ResourceLoader.load(path)
	if scene_res == null:
		push_error("LevelWithUi.load_map: Failed to load: %s" % path)
		return

	# Clear previous level if one exists
	if current_level_instance != null and is_instance_valid(current_level_instance):
		current_level_instance.queue_free()
		current_level_instance = null
		current_level_path = ""

	# Instantiate
	if not (scene_res is PackedScene):
		push_error("LevelWithUi.load_map: Resource is not a PackedScene: %s" % path)
		return

	var inst: Node = (scene_res as PackedScene).instantiate()
	if inst == null:
		push_error("LevelWithUi.load_map: Instantiation failed: %s" % path)
		return

	# Ensure viewport size is correct before inserting scene
	_update_viewport_size()

	# Add to the best place depending on what "game_viewport_node" is
	if game_viewport_node != null:
		# If game_viewport_node is a viewport itself (SubViewport / Viewport)
		if "size" in game_viewport_node:
			game_viewport_node.add_child(inst)

		# If it's a container, add to its internal viewport
		elif game_viewport_node.has_method("get_viewport"):
			var vp = game_viewport_node.get_viewport()
			if vp != null:
				vp.add_child(inst)
			else:
				# fallback
				game_frame.add_child(inst)
				push_warning("LevelWithUi.load_map: container.get_viewport() was null; added to game_frame instead.")
		else:
			# fallback
			game_frame.add_child(inst)
	else:
		# No viewport found; fallback
		game_frame.add_child(inst)
		push_warning("LevelWithUi.load_map: No viewport node found; added to game_frame.")

	current_level_instance = inst
	current_level_path = path
	print("LevelWithUi: loaded map:", path)
