extends "res://player/PlayerState.gd"

const JUMP_VSPEED = 150
const JUMP_HSPEED = 60


func enter(previous_state: String = '', args=null):
	anim_player.play("Grapple")


func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		var input_x = _get_input_x()
		emit_signal("state_change", "Jump", Vector2(JUMP_HSPEED * input_x, -JUMP_VSPEED))
