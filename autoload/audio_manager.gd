extends Node

const POOL_SIZE := 16

var _sfx_pool: Array[AudioStreamPlayer] = []
var _pool_index: int = 0
var _music_player: AudioStreamPlayer

func _ready() -> void:
	# Build SFX pool
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)

	# Music player
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.volume_db = -10.0  # Music slightly quieter than SFX by default
	add_child(_music_player)

# ── MUSIC ──────────────────────────────────────────────
func play_music(stream: AudioStream) -> void:
	if stream == null:
		return
	if _music_player.stream == stream and _music_player.playing:
		return  # Already playing, don't restart
	_music_player.stream = stream
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()

# ── SFX ────────────────────────────────────────────────
func play_sfx(stream: AudioStream, pitch_variance: bool = false) -> void:
	if stream == null:
		return
	var player := _get_next_player()
	player.stream = stream
	player.pitch_scale = randf_range(0.9, 1.1) if pitch_variance else 1.0
	player.play()

# ── HELPERS ────────────────────────────────────────────
func play_brick_sfx(brick_type: String) -> void:
	if SoundBank.BRICK_SOUNDS.has(brick_type):
		play_sfx(SoundBank.BRICK_SOUNDS[brick_type], true)

func play_ball_sfx(ball_type: String) -> void:
	if SoundBank.BALL_SOUNDS.has(ball_type):
		play_sfx(SoundBank.BALL_SOUNDS[ball_type], true)

func play_ball_lost() -> void:
	play_sfx(SoundBank.BALL_LOST)

# ── INTERNAL ───────────────────────────────────────────
func _get_next_player() -> AudioStreamPlayer:
	var player := _sfx_pool[_pool_index]
	_pool_index = (_pool_index + 1) % POOL_SIZE
	if player.playing:
		player.stop()
	return player

func play_ui_click(index: int = -1) -> void:
	var sounds = SoundBank.UI_CLICK.filter(func(s): return s != null)
	if sounds.is_empty():
		return
	if index >= 0 and index < sounds.size():
		play_sfx(sounds[index])  # Play specific sound
	else:
		play_sfx(sounds[randi() % sounds.size()])  # Random
