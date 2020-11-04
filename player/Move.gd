extends "res://player/OnGround.gd"


func enter(previous_state: String = '', v = Vector2.ZERO):
	velocity = v
	anim_player.play("Walk")
	_snap = true


func update(delta):
	if not owner.is_on_floor():
		coyote_timer.start(COYOTE_TIME)
		emit_signal("state_change", "Fall", velocity)
	_calculate_velocity(delta, ACCELRATION, FRICTION)
	if velocity.is_equal_approx(Vector2.ZERO) and _get_input_x() == 0:
		emit_signal("state_change", "Idle")
	.update(delta)
