extends Node

enum WindowMode {
	BORDERLESS,
	FULLSCREEN,
	WINDOWED,
}

enum Resolutions {
	_1280x720,
	_960x540,
	_640x360,
	_320x180,
}

const HIGHSCORE_FILE = "user://highscores.json"
const OPTIONS_FILE = "user://options.json"

var _resbackmap: Dictionary

var music_volume: float = 1.0 setget set_musicvol
var sfx_volume: float = 1.0 setget set_sfxvol
var screen_shake: bool = true setget set_screenshake
var window_mode: int setget set_windowmode
var resolution_mode: int = Resolutions._1280x720 setget set_resolutionmode
var resolution: Vector2 = Vector2(1280, 720) setget set_resolution, get_resolution
var player_name: String = "Player"


func _ready():
	window_mode = _get_windowmode()
	# set the resolution mapping from the resolution values to keys
	var res_keys = Resolutions.keys()
	var res_values = Resolutions.values()
	for i in range(len(res_keys)):
		_resbackmap[res_values[i]] = _get_resolution_as_vector(res_keys[i])
	_load()


func save():
	var file = File.new()
	var data: Dictionary = {
		'music_volume': music_volume,
		'sfx_volume': sfx_volume,
		'screen_shake': screen_shake,
		'window_mode': window_mode,
		'resolution_mode': resolution_mode,
		'resolution': resolution,
		'player_name': player_name,
	}
	file.open(OPTIONS_FILE, file.WRITE)
	file.store_line(to_json(data))
	file.close()


func _load():
	var file = File.new()
	file.open(OPTIONS_FILE, file.READ)
	var json = JSON.parse(file.get_as_text())
	file.close()
	if json.error != 0:
		push_warning("Error loading options")
		return
	var data := json.result as Dictionary
	self.music_volume = data['music_volume']
	self.sfx_volume = data['sfx_volume']
	self.screen_shake = data['screen_shake']
	self.resolution_mode = data['resolution_mode']
	self.resolution = data['resolution']
	self.window_mode = data['window_mode']
	self.player_name = data['player_name']


func _get_resolution_as_vector(string: String) -> Vector2:
	# expectes an input string in the format _<X>x<Y>
	# returns a Vector2(<X>, <Y>)
	var digits: Array = []
	var regex = RegEx.new()
	regex.compile("\\d+")
	for result in regex.search_all(string):
		digits.push_back(result.get_string().to_int())
	return Vector2(digits[0], digits[1])


func _get_windowmode() -> int:
	if OS.window_fullscreen:
		if OS.window_borderless:
			return WindowMode.BORDERLESS
		return WindowMode.FULLSCREEN
	return WindowMode.WINDOWED


func set_musicvol(value: float):
	music_volume = clamp(value, 0, 1)
	var bus_index = AudioServer.get_bus_index("Music")
	if music_volume > 0:
		AudioServer.set_bus_volume_db(
			bus_index,
			lerp(-30, 0, music_volume)
		)
	else:
		AudioServer.set_bus_mute(
			bus_index,
			true
		)


func set_sfxvol(value: float):
	sfx_volume = clamp(value, 0, 1)
	var bus_index = AudioServer.get_bus_index("Sfx")
	if sfx_volume > 0:
		AudioServer.set_bus_volume_db(
			bus_index,
			lerp(-30, 0, sfx_volume)
		)
	else:
		AudioServer.set_bus_mute(
			bus_index,
			true
		)


func set_screenshake(value: bool):
	screen_shake = value


func set_windowmode(value: int):
	window_mode = value
	match value:
		WindowMode.BORDERLESS:
			OS.window_borderless = true
			OS.window_fullscreen = true
		WindowMode.FULLSCREEN:
			OS.window_fullscreen = true
			OS.window_borderless = false
		WindowMode.WINDOWED:
			OS.window_borderless = false
			OS.window_fullscreen = false


func set_resolutionmode(value: int):
	if window_mode == WindowMode.BORDERLESS or window_mode == WindowMode.FULLSCREEN:
		return
	resolution_mode = value
	var res_vector = _resbackmap.get(value, Vector2.ZERO)
	if res_vector == Vector2.ZERO:
		push_error("Resolution does not exist in list of resolutions")
	self.resolution = res_vector


func set_resolution(value: Vector2):
	if window_mode == WindowMode.BORDERLESS or window_mode == WindowMode.FULLSCREEN:
		return
	resolution = value
	OS.window_size = value


func get_resolution():
	return resolution
