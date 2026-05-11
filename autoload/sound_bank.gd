extends Node

# ── MUSIC ──────────────────────────────────────────────────────
var MUSIC_MENU: AudioStream
var MUSIC_LEVEL_FOREST_1: AudioStream
var MUSIC_LEVEL_FOREST_2: AudioStream
var MUSIC_LEVEL_FOREST_3: AudioStream
var MUSIC_LEVEL_FIRE: AudioStream
var MUSIC_LEVEL_ICE: AudioStream

# ── BALLS ───────────────────────────────────────────────────────
var BALL_SOUNDS: Dictionary = {}

# ── BRICKS ──────────────────────────────────────────────────────
var BRICK_DAMAGE: AudioStream   # Hit but not destroyed
var BRICK_BREAK: AudioStream    # Destroyed

# ── CANNON ──────────────────────────────────────────────────────
var CANNON_FIRE: AudioStream

# ── UI ──────────────────────────────────────────────────────────
var UI_CLICK: Array[AudioStream] = []

# ── SCREENS ─────────────────────────────────────────────────────
var WIN_SCREEN: AudioStream
var LOSE_SCREEN: AudioStream
var BALL_LOST: AudioStream

func _ready() -> void:
	_load_sounds()

func _load_sounds() -> void:
	
	# Music
	MUSIC_MENU          = _try_load("res://assets/audio/music/maintheme.mp3")
	MUSIC_LEVEL_FOREST_1 = _try_load("res://assets/audio/music/forest1.mp3")
	MUSIC_LEVEL_FOREST_2 = _try_load("res://assets/audio/music/forest2.mp3")
	MUSIC_LEVEL_FOREST_3 = _try_load("res://assets/audio/music/forest3.mp3")
	MUSIC_LEVEL_FIRE    = _try_load("res://assets/audio/music/fire1.mp3")
	MUSIC_LEVEL_ICE     = _try_load("res://assets/audio/music/ice1.mp3")
	BALL_LOST = _try_load("res://assets/audio/sfx/losescreen.mp3")
	
	# Balls - keys match stats.ammo_name exactly
	BALL_SOUNDS = {
		"Basic Ball":  _try_load("res://assets/audio/sfx/basicball_edit.mp3"),
		"Beach Ball":  _try_load("res://assets/audio/sfx/beachball_edit.mp3"),
		"Ice Ball":    _try_load("res://assets/audio/sfx/iceball_edit.mp3"),
		"Tennis Ball": _try_load("res://assets/audio/sfx/tennisball_edit.mp3"),
		"Cannon Ball": _try_load("res://assets/audio/sfx/cannonball_edit.mp3"),
		# Use losescreen as the ball lost sound since you don't have a separate file
	}

	# Bricks
	BRICK_DAMAGE = _try_load("res://assets/audio/sfx/brickdamage.mp3")
	BRICK_BREAK  = _try_load("res://assets/audio/sfx/brickbreak.mp3")

	# Cannon
	CANNON_FIRE = _try_load("res://assets/audio/sfx/cannon_shot.mp3")

	# UI clicks - picked randomly at runtime
	UI_CLICK = [
		_try_load("res://assets/audio/sfx/uiclick1.mp3"),
		_try_load("res://assets/audio/sfx/uiclick2.mp3"),
		_try_load("res://assets/audio/sfx/uiclick3.mp3"),
	]

	# Screens
	WIN_SCREEN  = _try_load("res://assets/audio/sfx/winscreen.mp3")
	LOSE_SCREEN = _try_load("res://assets/audio/sfx/losescreen.mp3")

func _try_load(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("SoundBank: missing file -> " + path)
	return null
