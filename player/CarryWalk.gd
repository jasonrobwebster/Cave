extends "res://player/Carry.gd"


func enter(previous_state: String = '', item: Node = null):
	anim_player.play("CarryWalk")


func update(delta):
	if not owner.is_on_floor():
		coyote_timer.start(COYOTE_TIME)
		_drop()
		emit_signal("state_change", "Fall", velocity)
	_calculate_velocity(delta, ACCELRATION, FRICTION)
	if velocity.is_equal_approx(Vector2.ZERO) and _get_input_x() == 0:
		emit_signal("state_change", "CarryIdle")
	.update(delta)
