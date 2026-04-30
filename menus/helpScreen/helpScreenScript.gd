extends Control

# IMPORTANT NODES FOR SLIDING
@onready var slidingViewport = $ColorRect/CenterContainer/HBoxContainer/slideViewport
@onready var slidingRectangle = $ColorRect/CenterContainer/HBoxContainer/slideViewport/frame/slidinRect
@onready var slideContent = $ColorRect/CenterContainer/HBoxContainer/slideViewport/frame/slidinRect/slide/slideContent
@onready var slideNumber = $ColorRect/CenterContainer/HBoxContainer/slideViewport/frame/pageLabel

# THIS ARRAY WILL HOLD ALL THE SLIDES, CURRENTLY JUST PLACEHOLDERS
var slides = [
	preload("res://menus/helpScreen/tutorialSlides/slideOne.tscn"),
	preload("res://menus/helpScreen/tutorialSlides/slideTwo.tscn"),
	preload("res://menus/helpScreen/tutorialSlides/slideThree.tscn"),
	preload("res://menus/helpScreen/tutorialSlides/slideFour.tscn"),
	preload("res://menus/helpScreen/tutorialSlides/slideFive.tscn")
]

# TRACKS WHICH SLIDE WE ARE ON CURRENTLY, 0 THRU 3.
var index := 0

# PREVENT BUTTON SPAMMING WHILE ANIMATION HAPPENS
var animating := false

# INITIALIZE FIRST RECTANGE (SLIDE)
func _ready():
	updateSlide()

# HIDE HELP SCREEN AND RETURN TO TITLE
func _on_exit_button_pressed() -> void:
	#Audio
	AudioManager.play_ui_click(2)
	hide()

# LEFT ARROW
func _on_left_arrow_pressed() -> void:
	if animating:
		return
	
	#Audio
	AudioManager.play_ui_click(1)
	changeSlide(index - 1, -1)

# RIGHT ARROW
func _on_right_arrow_pressed() -> void:
	if animating:
		return
	#Audio
	AudioManager.play_ui_click(1)
	changeSlide(index + 1, 1)

# CHANGE RECTANGLE LOGIC (SLIDES)
func changeSlide(newIndex: int, direction: int):
	if newIndex < 0:
		newIndex = slides.size() - 1 #IF LEFT AT START, GO TO LAST SLIDE
	elif newIndex >= slides.size(): #IF RIGHT AT END, GO TO FIRST SLIDE
		newIndex = 0

	animating = true

# RECTANGLE SLIDE SIZE AND WHICH WAY (FLIPS ON VALUE 1/-1)
	var width = slidingViewport.size.x
	var exitPosition = Vector2(-direction * width, 0)
	var enterPosition = Vector2(direction * width, 0)

# TEMPORARY ANIMATION CONTROLLER
	var tween = create_tween()

	# SLIDE CURRENT RECTANGLE OUT
	tween.tween_property(slidingRectangle, "position", exitPosition, 0.25) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	# OFFSCREEN TELEPORT STUFF
	tween.tween_callback(func():
		index = newIndex
		updateSlide()
		slidingRectangle.position = enterPosition
	)

	# SLIDE NEW RECTANGLE IN
	tween.tween_property(slidingRectangle, "position", Vector2.ZERO, 0.25) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

	# ANIMATION DONE, BUTTONS WORK AGAIN
	tween.tween_callback(func():
		animating = false
	)

# UPDATES WHAT YOU SEE
func updateSlide():
	# CLEAR PREVIOUS SLIDE
	for child in slideContent.get_children():
		child.queue_free()
	
	# ADD NEW SLIDE 
	var inst = slides[index].instantiate()
	slideContent.add_child(inst)

	# MAKE INST (SCENE) FILL FULL RECTANGLE
	if inst is Control:
		inst.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# UPDATE PAGE NUMBER #/4
	slideNumber.text = str(index+1) + " / " + str(slides.size())
