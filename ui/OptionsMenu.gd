extends VBoxContainer

onready var windowmode_options := $GridContainer/WindowOptions
onready var resolution_options := $GridContainer/ResolutionOptions
onready var music_slider := $GridContainer/MusicSlider
onready var sfx_slider := $GridContainer/SoundSlider
onready var screen_toggle := $GridContainer/ShakeToggle


func _ready():
	add_options()
	sync_to_options()


func add_options():
	var window_options = Options.WindowMode.keys()
	for option in window_options:
		windowmode_options.add_item(
			_sanctify_string(option), 
			Options.WindowMode.get(option)
		)
	var res_options = Options.Resolutions.keys()
	for option in res_options:
		resolution_options.add_item(
			_sanctify_string(option), 
			Options.Resolutions.get(option)
		)


func sync_to_options():
	windowmode_options.selected = Options.window_mode
	resolution_options.disabled = (Options.window_mode != Options.WindowMode.WINDOWED)
	music_slider.value = Options.music_volume
	sfx_slider.value = Options.sfx_volume
	screen_toggle.pressed = Options.screen_shake


static func _sanctify_string(string: String) -> String:
	var out = string.capitalize()
	out = out.strip_edges()
	return out


func _on_WindowOptions_item_selected(index):
	Options.window_mode = index
	resolution_options.disabled = (Options.window_mode != Options.WindowMode.WINDOWED)


func _on_ResolutionOptions_item_selected(index):
	Options.resolution_mode = index


func _on_MusicSlider_value_changed(value):
	Options.music_volume = value


func _on_SoundSlider_value_changed(value):
	Options.sfx_volume = value


func _on_ShakeToggle_toggled(button_pressed):
	Options.screen_shake = button_pressed


func _on_OptionsPanel_visibility_changed():
	sync_to_options()
	windowmode_options.grab_focus()
