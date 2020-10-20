extends "res://player/OnGround.gd"

const ACCELRATION := 25
const FRICTION := 25


func enter(args=null):
	anim_player.play("Walk")
	_snap = true


func update(delta):
	if not owner.is_on_floor():
		emit_signal("state_change", "Jump", velocity)
		coyote_timer.start(COYOTE_TIME)
	
	var fdelta: float = delta * global.TARGET_FPS
	var input_x := _get_input_x()
	if input_x != 0:
		velocity.x = move_toward(
			velocity.x, 
			input_x * MAX_MOVE_SPEED, 
			ACCELRATION * fdelta
		)
		sprite.flip_h = input_x > 0
		sprite.offset.x = - int(input_x > 0)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			FRICTION * fdelta
		)
		if velocity.is_equal_approx(Vector2.ZERO):
			emit_signal("state_change", "Idle")
	.update(delta)
