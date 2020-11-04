extends "res://player/Motion.gd"

const ACCELERATION := 5
const FRICTION := 0
const MID_VSPEED := 30
const HOLD_SPEED := 60
const FORWARD_HSPEED := 10

var can_hold := false

var _hold_bottom := false
var _hold_top := false


func enter(previous_state: String = '', v: Vector2 = Vector2.ZERO):
	velocity = v
	_snap = false


func update(delta):
	if Input.is_action_just_pressed("jump") and coyote_timer.time_left > 0:
		coyote_timer.stop()
		emit_signal("state_change", "Jump", Vector2(velocity.x,  global.up_direction.y * JUMP_FORCE))
	
	var fall_speed := velocity.dot(global.up_direction)
	if fall_speed > MID_VSPEED:
		if abs(velocity.x) > FORWARD_HSPEED and anim_player.current_animation != "FallForwardUp":
			anim_player.play("FallForwardUp")
		elif abs(velocity.x) <= FORWARD_HSPEED and anim_player.current_animation != "FallUp":
			anim_player.play("FallUp")
	elif -MID_VSPEED <= fall_speed and fall_speed <= MID_VSPEED:
		if abs(velocity.x) > FORWARD_HSPEED and anim_player.current_animation != "FallForwardMid":
			anim_player.play("FallForwardMid")
		elif abs(velocity.x) <= FORWARD_HSPEED and anim_player.current_animation != "FallMid":
			anim_player.play("FallMid")
		anim_player.play("JumpMid")
	elif fall_speed < -MID_VSPEED:
		if abs(velocity.x) > FORWARD_HSPEED and anim_player.current_animation != "FallForwardDown":
			anim_player.play("FallForwardDown")
		elif abs(velocity.x) <= FORWARD_HSPEED and anim_player.current_animation != "FallDown":
			anim_player.play("FallDown")
	
	if owner.is_on_floor() and fall_speed <= 0:
		emit_signal("state_change", "Land")
	
	if can_hold and fall_speed < HOLD_SPEED and owner.is_on_wall():
		velocity = Vector2.ZERO
		emit_signal("state_change", "Hold")
	
	_calculate_velocity(delta, ACCELERATION, FRICTION)
	.update(delta)


func _update_hold():
	can_hold = _hold_bottom and not _hold_top


func _on_HoldBottom_body_entered(body):
	if body.is_in_group("environment"):
		_hold_bottom = true
		_update_hold()


func _on_HoldBottom_body_exited(body):
	if body.is_in_group("environment"):
		_hold_bottom = false
		_update_hold()


func _on_HoldTop_body_entered(body):
	if body.is_in_group("environment"):
		_hold_top = true
		_update_hold()


func _on_HoldTop_body_exited(body):
	if body.is_in_group("environment"):
		_hold_top = false
		_update_hold()
