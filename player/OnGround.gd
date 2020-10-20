extends "res://player/Motion.gd"


func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		emit_signal("state_change", "Jump", velocity + global.up_direction * JUMP_FORCE)
	.handle_input(event)
