extends "res://player/Motion.gd"

const ACCELERATION := 1
const FRICTION := 0
const HOVER_SPEED := 30

func enter(v: Vector2 = Vector2.ZERO):
	velocity = v
	anim_player.play("JumpUp")
	_snap = false


func update(delta):
	var jump_speed := velocity.dot(global.up_direction)
	if jump_speed > HOVER_SPEED and anim_player.current_animation != "JumpDown":
		anim_player.play("JumpDown")
	elif -HOVER_SPEED <= jump_speed and jump_speed <= HOVER_SPEED and anim_player.current_animation != "JumpMid":
		anim_player.play("JumpMid")
	elif jump_speed < -HOVER_SPEED and anim_player.current_animation != "JumpUp":
		anim_player.play("JumpUp")
	
	if Input.is_action_just_pressed("jump") and coyote_timer.time_left > 0:
		velocity.y = 0
		velocity += global.up_direction * JUMP_FORCE
		coyote_timer.stop()
	
	if owner.is_on_floor() and jump_speed <= 0:
		emit_signal("state_change", "Move")
	
	var fdelta: float = delta * global.TARGET_FPS
	var input_x := _get_input_x()
	if input_x != 0:
		velocity.x = move_toward(
			velocity.x, 
			input_x * MAX_MOVE_SPEED, 
			ACCELERATION * fdelta
		)
		sprite.flip_h = input_x > 0
		sprite.offset.x = - int(input_x > 0)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			FRICTION * fdelta
		)
	.update(delta)
