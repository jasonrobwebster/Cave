extends "res://player/Motion.gd"

const HURT_TIME = 0.75
const FRICTION = 25


func enter(previous_state: String = '', v: Vector2 = Vector2.ZERO):
	anim_player.play("Hurt")
	velocity = v
	$Timer.start(HURT_TIME)


func update(delta):
	if !owner.is_on_floor():
		$Timer.start(HURT_TIME)
	_calculate_velocity(delta, 0, FRICTION * float(owner.is_on_floor()))
	.update(delta)


func handle_input(_event):
	# called during _unhandled_input
	# don't handle input in this state
	pass


func _on_Timer_timeout():
	if !active:
		return
	if owner.is_on_floor():
		emit_signal("state_change", "Idle")
	else:
		emit_signal("state_change", "Fall")
