extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.lives_changed.connect(_on_lives_changed)
	text = "Lives: " + str(GameManager.lives)

func _on_lives_changed(new_lives):
	text = "Lives: " + str(new_lives)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
