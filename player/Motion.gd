extends "res://player/PlayerState.gd"

const MAX_FALL_SPEED := 400
const MAX_MOVE_SPEED := 64
const MAX_DECCELERATION := 50
const JUMP_FORCE := 200
const COYOTE_TIME := 0.1
const RUN_MULT := 0.5

var _snap: bool


func update(delta):
	_apply_gravity(delta)
	_bring_speed_to_max(delta)
	_move()


func _apply_gravity(delta):
	var fdelta: float = delta * global.TARGET_FPS
	velocity -= global.gravity * global.up_direction * fdelta


func _bring_speed_to_max(delta):
	var fdelta: float = delta * global.TARGET_FPS
	var input_run := _get_input_run(RUN_MULT)
	if abs(velocity.x) > MAX_MOVE_SPEED * input_run:
		velocity.x = move_toward(
			velocity.x,
			sign(velocity.x) * MAX_MOVE_SPEED * input_run,
			MAX_DECCELERATION * fdelta
		)
	if abs(velocity.y) > MAX_FALL_SPEED:
		velocity.y = move_toward(
			velocity.y,
			sign(velocity.y) * MAX_FALL_SPEED,
			MAX_DECCELERATION * fdelta
		)


func _calculate_velocity(delta, acceleration, friction):
	var fdelta: float = delta * global.TARGET_FPS
	var input_x := _get_input_x()
	var input_run := _get_input_run(RUN_MULT)
	if input_x != 0 and acceleration != 0:
		velocity.x = move_toward(
			velocity.x, 
			input_x * MAX_MOVE_SPEED * input_run, 
			acceleration * fdelta * input_run
		)
		_update_image(input_x)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			friction * fdelta
		)


func _update_image(input_x):
	pivot.scale.x = 1 if input_x > 0 else -1


func _move():
	velocity = owner.move_and_slide_with_snap(
		velocity, 
		-global.up_direction * float(_snap), 
		global.up_direction
	)
