extends "res://player/OnGround.gd"


func enter(_previous_state: String = '', _args=null):
	anim_player.play("Idle")
	_snap = true


func update(delta):
	var input_x := _get_input_x()
	if input_x != 0:
		emit_signal("state_change", "Move")
	.update(delta)
