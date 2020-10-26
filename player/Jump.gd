extends "res://player/Motion.gd"

const ACCELERATION := 5
const FRICTION := 0
const HOVER_SPEED := 30
const HOLD_SPEED := 30

var can_hold := false

var _hold_bottom := false
var _hold_top := false


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
	
	if can_hold and jump_speed < HOVER_SPEED and owner.is_on_wall():
		velocity = Vector2.ZERO
		emit_signal("state_change", "Hold")
	
	var fdelta: float = delta * global.TARGET_FPS
	var input_x := _get_input_x()
	if input_x != 0:
		velocity.x = move_toward(
			velocity.x, 
			input_x * MAX_MOVE_SPEED, 
			ACCELERATION * fdelta
		)
		pivot.scale.x = -1 if input_x > 0 else 1
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			FRICTION * fdelta
		)
	.update(delta)


func _update_hold():
	can_hold = _hold_bottom and not _hold_top


func _on_HoldBottom_body_entered(body):
	_hold_bottom = true
	_update_hold()


func _on_HoldBottom_body_exited(body):
	_hold_bottom = false
	_update_hold()


func _on_HoldTop_body_entered(body):
	_hold_top = true
	_update_hold()


func _on_HoldTop_body_exited(body):
	_hold_top = false
	_update_hold()
