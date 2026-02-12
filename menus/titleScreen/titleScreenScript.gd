extends Control
@onready var exitScreen = $exitConfirm
@onready var yesButton = $exitConfirm/center/Panel/content/buttons/yesButton
@onready var noButton = $exitConfirm/center/Panel/content/buttons/noButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_exit_pressed() -> void:
	exitScreen.show()
