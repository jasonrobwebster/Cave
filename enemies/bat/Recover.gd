extends "res://enemies/bat/BatState.gd"

const MAX_XDIST := 48
const MAX_YDIST := 24
const MIN_XDIST := 24
const MIN_YDIST := 16
const MAX_TIME := 2
const WAIT_TIME := 0.5
const MAX_HSPEED := 80
const MAX_VSPEED := 60
const X_ACCELERATION := 2
const Y_ACCELERATION := 4
const FRICTION := 5

var _target_pos: Vector2 = Vector2.ZERO
var _player: Node = null

onready var timer: Timer = $Timer
onready var wait_timer: Timer = $WaitTimer


func enter(previous_state: String = '', seek_pos: Vector2 = start_pos):
	var random_pos1 := Vector2(
		_rng.randf_range(-MAX_XDIST, -MIN_XDIST),
		-_rng.randf_range(MIN_YDIST, MAX_YDIST)
	)
	var random_pos2 := Vector2(
		_rng.randf_range(MIN_XDIST, MAX_XDIST),
		-_rng.randf_range(MIN_YDIST, MAX_YDIST)
	)
	var target_pos1 := seek_pos + random_pos1
	var target_pos2 := seek_pos + random_pos2
	if (target_pos1 - owner.global_position).length() < (target_pos2 - owner.global_position).length():
		_target_pos = target_pos1
	else:
		_target_pos = target_pos2
	timer.start(MAX_TIME)
	wait_timer.start(WAIT_TIME)
	anim_player.play("Wander")


func update(delta: float):
	if wait_timer.time_left > 0:
		return
	
	var fdelta := delta * global.TARGET_FPS
	
	if timer.time_left <= 0:
		velocity = velocity.move_toward(Vector2.ZERO, fdelta * FRICTION)
		.update(delta)
		if velocity.length() < 0.2 and _player and line_of_sight.get_collider() == _player:
			emit_signal("state_change", "Attack", _player)
			return
		if velocity.length() < 0.2:
			emit_signal("state_change", "Idle")
		return
	
	var move_dist: Vector2 = _target_pos - owner.global_position
	var move_dist_normalized: Vector2 = move_dist.normalized()
	
	if abs(move_dist.x) > velocity.x / FRICTION + 1:
		velocity.x = move_toward(
			velocity.x,
			move_dist_normalized.x * MAX_HSPEED,
			fdelta * X_ACCELERATION
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			fdelta * FRICTION
		)
	if abs(move_dist.y) > velocity.y / FRICTION + 2:
		velocity.y = move_toward(
			velocity.y,
			move_dist_normalized.y * MAX_VSPEED,
			fdelta * Y_ACCELERATION
		)
	else:
		velocity.y = move_toward(
			velocity.y,
			0,
			fdelta * FRICTION
		)
	.update(delta)
	if velocity.length() > 0.05:
		return
	if _player:
		line_of_sight.cast_to = (_player.center.global_position - owner.global_position) * 2
		line_of_sight.force_raycast_update()
		if line_of_sight.get_collider() == _player:
			emit_signal("state_change", "Attack", _player)
			return
	emit_signal("state_change", "Idle")


func _on_PlayerDetection_body_entered(body: Node):
	if body.is_in_group("player"):
		_player = body


func _on_PlayerDetection_body_exited(body: Node):
	if body.is_in_group("player"):
		_player = null

