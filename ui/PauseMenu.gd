extends Control

export(NodePath) var focus_button

var paused: bool setget set_paused

onready var paused_panel := $PausedPanel
onready var options_panel := $OptionsPanel
onready var quit_button := $PausedPanel/MarginContainer/VBoxContainer/Quit


func _ready():
	visible = false
	if OS.get_name() == "HTML5":
		# hide the quit button
		quit_button.visible = false


func set_paused(value: bool):
	paused = value
	get_tree().paused = paused
	visible = paused
	if paused:
		paused_panel.visible = true
		options_panel.visible = false
	if paused and focus_button:
		get_node(focus_button).grab_focus()


func _input(event):
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause():
	var pause_state: bool = not get_tree().paused
	self.paused = pause_state


func _on_Quit_pressed():
	var current_scene := get_tree().current_scene
	if current_scene.name == "MainMenu":
		get_tree().quit()
	else:
		self.paused = false
		SceneManager.transition_to_main_menu()


func _on_Options_pressed():
	paused_panel.visible = false
	options_panel.visible = true


func _on_options_back_button_pressed():
	options_panel.visible = false
	paused_panel.visible = true
	Options.save()


func _on_Resume_pressed():
	_toggle_pause()
