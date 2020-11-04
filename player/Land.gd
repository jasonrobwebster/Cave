extends "res://player/OnGround.gd"


func enter(previous_state: String = '', args=null):
	anim_player.play("Land")
	_snap = true


func exit():
	sprite.scale.x = -1 if sprite.scale.x < 0 else 1


func update(delta):
	if not owner.is_on_floor():
		coyote_timer.start(COYOTE_TIME)
		emit_signal("state_change", "Fall", velocity)
	_calculate_velocity(delta, ACCELRATION, FRICTION)
	.update(delta)


func _go_to_Ground_state():
	if velocity.x == 0:
		emit_signal("state_change", "Idle")
	else:
		emit_signal("state_change", "Move", velocity)
