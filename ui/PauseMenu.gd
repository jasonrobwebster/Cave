extends Control

export(NodePath) var focus_button

onready var paused_panel := $PausedPanel
onready var options_panel := $OptionsPanel


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause():
	var pause_state: bool = not get_tree().paused
	get_tree().paused = pause_state
	visible = pause_state
	if pause_state:
		paused_panel.visible = true
		options_panel.visible = false
	if pause_state and focus_button:
		get_node(focus_button).grab_focus()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Options_pressed():
	paused_panel.visible = false
	options_panel.visible = true


func _on_options_back_button_pressed():
	options_panel.visible = false
	paused_panel.visible = true


func _on_Resume_pressed():
	_toggle_pause()
