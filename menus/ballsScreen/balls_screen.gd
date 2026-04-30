extends Control

@export var ball_info_scene: PackedScene

# BALL ITEM FORMAT WE MADE
@export var ball_item_scene: PackedScene

# CAROUSEL TUNING
@export var visible_slots: int = 5 # HOW MANY BALLS ARE VISIBLE (must be odd)
@export var spacing: float = 220.0 # HORIZONTAL SPACING BETWEEN BALLS
@export var center_scale: float = 1.25 # SCALE OF CENTER BALL
@export var side_scale: float = 0.85 # SCALE OF SIDE BALLS
@export var tween_time: float = 0.25 # ANIMATION DURATION 
@export var y_offset: float = 0.0 # VERTICAL OFFSET FOR ALL BALLS

# CAROUSEL VARIABLE
@onready var carousel_root: Control = $CarouselRoot

# BALL SECTION
# ID TO SELECT, NAME TO HOVER, TEX IS TEXTURE
var balls: Array[Dictionary] = [
	{"id":"basic", "name":"Basic Ball", "tex":"res://assets/spritesArt/ball/ball.png"},
	{"id":"ice",   "name":"Ice Ball",   "tex":"res://assets/spritesArt/ball/iceball.png"},
	{"id":"fire",  "name":"Tennis Ball",  "tex":"res://assets/spritesArt/ball/tennisBall.png"},
	{"id":"cannon",  "name":"Cannon Ball",  "tex":"res://assets/spritesArt/ball/Cannon_Ball_Big.png"},
	{"id":"beach",  "name":"Beach Ball",  "tex":"res://assets/spritesArt/ball/BeachBall.png"},
]


var selected_index: int = 0 # WHICH BALL IS CURRENTLY CENTERED
var slot_nodes: Array[TextureButton] = [] # THE VISIBLE SLOT INCREASES


# RUNS WHEN LOADED
func _ready() -> void:
	# ENSURE ODD AND >= 3
	if visible_slots < 3:
		visible_slots = 3
	if visible_slots % 2 == 0:
		visible_slots += 1

	_spawn_slots() # CREATE THE VISIBLE SLOTS
	_update_slots(true) # POSITION WITH ANIMATION
	
	_apply_hover_to_all_buttons(self)


func _unhandled_input(event: InputEvent) -> void:
	# KEYBOARD INPUT
	if event.is_action_pressed("ui_left"):
		_move(-1)
	elif event.is_action_pressed("ui_right"):
		_move(1)

	# SCROLL WHEEL
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_move(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_move(1)


# MOVE CAROUSEL LEFT/RIGHT
func _move(dir: int) -> void:
	if balls.is_empty():
		return
	# Audio
	AudioManager.play_ui_click(2)
# ALLOWS FOR LOOPING & UPDATE WITH ANIMATION
	selected_index = wrapi(selected_index + dir, 0, balls.size())
	_update_slots(true)


# SPAWN VISIBLE SLOTS
func _spawn_slots() -> void:
	# REMOVE OLD BALLS IF RELOADING
	for c in carousel_root.get_children():
		c.queue_free()
	slot_nodes.clear()

	# SPAWN ONLY THE VISIBLE BALLS
	for s in range(visible_slots):
		var item := ball_item_scene.instantiate() as TextureButton
		item.name = "Slot_%d" % s

		# BIND SLOT INDEX SAFELY (no lambdas)
		item.pressed.connect(Callable(self, "_on_slot_pressed").bind(s))
		
		add_hover_effect(item)

		carousel_root.add_child(item)
		slot_nodes.append(item)


# WHEN A BALL IS CLICKED
func _on_slot_pressed(slot_i: int) -> void:
	if balls.is_empty():
		return
	# Audio
	AudioManager.play_ui_click(2)
	var center_slot: int = visible_slots >> 1 # INT DIVISION BY 2
	var offset: int = slot_i - center_slot

	# CLICKED SIDE BALL -> MOVE BALL TO CENTER
	if offset != 0:
		selected_index = wrapi(selected_index + offset, 0, balls.size())
		_update_slots(true)
		return

	# CLICKED CENTER BALL -> WILL CHANGE SCREEN (later, not rn)
	var b: Dictionary = balls[selected_index]
	print("Clicked centered:", b["id"], "-", b["name"])


# UPDATE BALL SLOTS
func _update_slots(animated: bool) -> void:
	if slot_nodes.is_empty():
		return
	if balls.is_empty():
		return

	var center: Vector2 = carousel_root.size * 0.5
	var center_slot: int = visible_slots >> 1

	# ONLY CREATE TWEEN IF ANIMATING
	var tween: Tween = null
	if animated:
		tween = create_tween()
		tween.set_parallel(true)

	for slot_i in range(visible_slots):
		var node: TextureButton = slot_nodes[slot_i]
		var offset: int = slot_i - center_slot

		# DECIDE WHICH BALL GOES IN THIS SLOT
		var data_index: int = wrapi(selected_index + offset, 0, balls.size())
		var data: Dictionary = balls[data_index]

		# DEBUG TOOLTIP (optional)
		node.tooltip_text = str(data["name"])
		
		# APPLY PER-BALL TEXTURE
		if data.has("tex"):
			var tex_path := String(data["tex"])
			var tex := load(tex_path) as Texture2D
			if tex != null:
				node.texture_normal = tex

		# POSITION OF BALL
		var target_pos: Vector2 = Vector2(center.x + float(offset) * spacing, center.y + y_offset)
		target_pos -= node.size * 0.5

		# SCALE CALCULATION BASED OFF CENTER
		var dist: int = abs(offset)
		var t: float = 0.0
		if center_slot > 0:
			t = clamp(float(dist) / float(center_slot), 0.0, 1.0)
		var target_scale: float = lerp(center_scale, side_scale, t)

		# CENTER BALL DRAWS ON TOP
		node.z_index = 100 - dist * 10

# ANIMATE OR INSTANTLY APPLY
		if animated and tween != null:
			tween.tween_property(node, "position", target_pos, tween_time)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(node, "scale", Vector2.ONE * target_scale, tween_time)\
				.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		else:
			node.position = target_pos
			node.scale = Vector2.ONE * target_scale


# EXIT TO MAIN SCREEN
func _on_exit_button_pressed() -> void:
	# Audio
	AudioManager.play_ui_click(2)
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")


func add_hover_effect(btn: BaseButton):
	btn.mouse_entered.connect(func():
		btn.modulate = Color(1.2, 1.2, 1.2, 1)
	)

	btn.mouse_exited.connect(func():
		btn.modulate = Color(1, 1, 1, 1)
	)


func _apply_hover_to_all_buttons(node):
	for child in node.get_children():
		if child is BaseButton:
			add_hover_effect(child)
		_apply_hover_to_all_buttons(child)


func _on_info_button_pressed():
	var stats = get_tree().get_first_node_in_group("gamestats")
	stats.info_target_ball = balls[selected_index]["name"]
	get_tree().change_scene_to_file("res://scenes/ballInfoScreen/ballInfoScreen.tscn")
