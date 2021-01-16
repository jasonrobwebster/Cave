extends Control

export(NodePath) var focus_button


func _ready():
	visible = false


func _input(event):
	if event.is_action_pressed("pause"):
		var pause_state: bool = not get_tree().paused
		get_tree().paused = pause_state
		visible = pause_state
		if pause_state and focus_button:
			get_node(focus_button).grab_focus()


func _on_Quit_pressed():
	get_tree().quit()
