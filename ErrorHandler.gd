extends Node

# ============================================================
#  ErrorHandler — Production-grade singleton logger
#  Autoload as "ErrorHandler" in Project Settings
# ============================================================

# --- Configuration ---
const LOG_PATH        = "user://error_log.txt"
const OLD_LOG_PATH    = "user://error_log_old.txt"
const MAX_FILE_BYTES  = 1_000_000   # 1 MB before rotation
const BUFFER_LIMIT    = 20          # flush to disk after N entries
const FLUSH_INTERVAL  = 5.0         # also flush every N seconds

# --- Log Levels ---
enum Level { DEBUG, INFO, WARNING, ERROR, FATAL }
var min_level: Level = Level.DEBUG  # tighten in production builds

# --- Signals — other nodes can react without coupling ---
signal error_logged(entry: Dictionary)
signal warning_logged(entry: Dictionary)
signal fatal_logged(entry: Dictionary)

# --- Internal state ---
var _buffer: Array[Dictionary] = []
var _flush_timer: float = 0.0
var _session_id: String = ""

# ============================================================
#  LIFECYCLE
# ============================================================

func _ready() -> void:
	_session_id = _generate_session_id()
	_rotate_log_if_needed()
	_write_session_header()
	# Flush remaining buffer on clean exit
	get_tree().root.connect("tree_exiting", _flush)

func _process(delta: float) -> void:
	_flush_timer += delta
	if _flush_timer >= FLUSH_INTERVAL:
		_flush_timer = 0.0
		_flush()

# ============================================================
#  PUBLIC API
# ============================================================

## Log a debug message — stripped in release if you wrap with OS.is_debug_build()
func debug(message: String, context: String = "") -> void:
	if min_level > Level.DEBUG:
		return
	_record(Level.DEBUG, message, context)

## General information checkpoint
func info(message: String, context: String = "") -> void:
	if min_level > Level.INFO:
		return
	_record(Level.INFO, message, context)

## Something unexpected but recoverable
func warning(message: String, context: String = "") -> void:
	if min_level > Level.WARNING:
		return
	var entry = _record(Level.WARNING, message, context)
	push_warning("[%s] %s" % [context if context else "?", message])
	warning_logged.emit(entry)

## Something broke — execution can continue but something is wrong
func error(message: String, context: String = "") -> void:
	if min_level > Level.ERROR:
		return
	var entry = _record(Level.ERROR, message, context, get_stack())
	push_error("[%s] %s" % [context if context else "?", message])
	error_logged.emit(entry)

## Unrecoverable — log, flush, quit
func fatal(message: String, context: String = "") -> void:
	var entry = _record(Level.FATAL, message, context, get_stack())
	push_error("FATAL [%s] %s" % [context if context else "?", message])
	_flush()
	fatal_logged.emit(entry)
	# Give signal listeners one frame to react (show crash screen etc.)
	await get_tree().process_frame
	get_tree().quit(1)

# ============================================================
#  INTERNAL
# ============================================================

func _record(
	level: Level,
	message: String,
	context: String,
	stack: Array = []
) -> Dictionary:
	var entry: Dictionary = {
		"level":     Level.keys()[level],
		"timestamp": _timestamp(),
		"session":   _session_id,
		"context":   context if context != "" else "global",
		"message":   message,
		"stack":     stack,
	}
	_buffer.append(entry)
	if _buffer.size() >= BUFFER_LIMIT:
		_flush()
	return entry

func _flush() -> void:
	if _buffer.is_empty():
		return

	var file: FileAccess
	if FileAccess.file_exists(LOG_PATH):
		file = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE)
	else:
		file = FileAccess.open(LOG_PATH, FileAccess.WRITE)

	if file == null:
		push_warning("ErrorHandler: cannot open log — %s" % error_string(FileAccess.get_open_error()))
		return

	file.seek_end()
	for entry in _buffer:
		file.store_string(_format_entry(entry))
	file.close()
	_buffer.clear()

func _format_entry(entry: Dictionary) -> String:
	var line = "[%s] [%s] [%s] %s\n" % [
		entry["level"],
		entry["timestamp"],
		entry["context"],
		entry["message"]
	]
	if entry["stack"].size() > 0:
		line += "  Stack:\n"
		for frame in entry["stack"]:
			line += "    -> %s:%s in %s()\n" % [
				frame.get("source", "?"),
				frame.get("line",   "?"),
				frame.get("function", "?")
			]
	return line

func _rotate_log_if_needed() -> void:
	if not FileAccess.file_exists(LOG_PATH):
		return
	var size = FileAccess.get_file_as_bytes(LOG_PATH).size()
	if size >= MAX_FILE_BYTES:
		# Keep one generation of old log
		if FileAccess.file_exists(OLD_LOG_PATH):
			DirAccess.remove_absolute(OLD_LOG_PATH)
		DirAccess.rename_absolute(LOG_PATH, OLD_LOG_PATH)

func _write_session_header() -> void:
	var header  = "\n" + "=".repeat(60) + "\n"
	header += "  SESSION : %s\n" % _session_id
	header += "  STARTED : %s\n" % _timestamp()
	header += "  PLATFORM: %s  |  DEBUG: %s\n" % [
		OS.get_name(),
		str(OS.is_debug_build())
	]
	header += "  VERSION : %s\n" % ProjectSettings.get_setting("application/config/version", "unset")
	header += "=".repeat(60) + "\n"

	# Write header directly — buffer not ready yet
	var file = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE if FileAccess.file_exists(LOG_PATH) else FileAccess.WRITE)
	if file:
		file.seek_end()
		file.store_string(header)
		file.close()

func _generate_session_id() -> String:
	# Short unique ID per run — useful when grepping multi-session logs
	return "%x" % (Time.get_unix_time_from_system() as int)

func _timestamp() -> String:
	var t = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		t.year, t.month, t.day, t.hour, t.minute, t.second
	]
