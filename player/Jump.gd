extends "res://player/Motion.gd"

const ACCELERATION := 5
const FRICTION := 0

onready var audio_jump := $AudioJump


func enter(previous_state: String = '', v: Vector2 = Vector2.ZERO):
	velocity = v
	audio_jump.play()
	match previous_state:
		'Idle':
			anim_player.play("JumpUp")
		'Walk', 'Run':
			anim_player.play("JumpForward")
		_:
			anim_player.play("JumpUp")
	_snap = false


func exit():
	anim_player.stop()
	sprite.scale.x = -1 if sprite.scale.x < 0 else 1
	sprite.scale.y = 1


func update(delta):
	var fall_speed := velocity.dot(global.up_direction)
	if owner.is_on_floor() and fall_speed <= 0:
		emit_signal("state_change", "Land", velocity)
	_calculate_velocity(delta, ACCELERATION, FRICTION)
	.update(delta)


func _go_to_Fall_state():
	emit_signal("state_change", "Fall", velocity)
