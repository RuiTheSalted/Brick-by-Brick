extends Control

@onready var music_slider = $centerSettings/backgroundPanel/content/settingsVbox/musicRow/musicSlider
@onready var sfx_slider = $centerSettings/backgroundPanel/content/settingsVbox/sfxRow/sfxSlider

func _ready() -> void:
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))) * 100
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

func _on_music_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value / 100.0))

func _on_sfx_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))

func _on_home_button_pressed() -> void:
	AudioManager.play_ui_click()

	var stats = get_tree().get_first_node_in_group("gamestats")
	if stats:
		stats.reset_game()

	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/titleScreen/mainScreen.tscn")

func _on_continue_button_pressed() -> void:
	AudioManager.play_ui_click()
	get_tree().paused = false
	hide()

func _on_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_tree().paused = false
		hide()


func _on_restart_button_pressed():
	var stats = get_tree().get_first_node_in_group("gamestats")
	get_tree().paused = false
	stats.restart_game()
