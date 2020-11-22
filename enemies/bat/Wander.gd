extends "res://enemies/bat/BatState.gd"

const MIN_XDIST := 32
const MIN_YDIST := 4
const MAX_XDIST := 64
const MAX_YDIST := 8
const MAX_HSPEED := 80
const MAX_VSPEED := 120
const X_ACCELERATION := 2
const Y_ACCELERATION := 4
const FRICTION := 5
const MAX_TIME := 6

var _target_pos: Vector2
var _player: Node = null

onready var timer = $Timer


func enter(_previous_state: String = '', _args=null):
	velocity = Vector2.ZERO
	var pos: Vector2 = owner.global_position
	
	var xpos_choices := [
		_rng.randf_range(
			start_pos.x - MAX_XDIST, 
			max(pos.x - MIN_XDIST, start_pos.x - MAX_XDIST)
		), 
		_rng.randf_range(
			min(pos.x + MIN_XDIST, start_pos.x + MAX_XDIST),
			start_pos.x + MAX_XDIST
		),
	]
	xpos_choices.erase(start_pos.x - MAX_XDIST)
	xpos_choices.erase(start_pos.x + MAX_XDIST)
	
	var ypos_choices := [
		_rng.randf_range(
			start_pos.y - MAX_YDIST, 
			max(pos.y - MIN_YDIST, start_pos.y - MAX_YDIST)
		), 
		_rng.randf_range(
			min(pos.y + MIN_YDIST, start_pos.y + MAX_YDIST),
			start_pos.y + MAX_YDIST
		),
	]
	ypos_choices.erase(start_pos.y - MAX_YDIST)
	ypos_choices.erase(start_pos.y + MAX_YDIST)
	
	var xpos: float = xpos_choices[_rng.randi() % len(xpos_choices)]
	var ypos: float = ypos_choices[_rng.randi() % len(ypos_choices)]
	
	_target_pos = Vector2(xpos, ypos)
	var seek := 0.0
	if _previous_state == 'Idle':
		seek = anim_player.current_animation_position
	anim_player.play("Wander")
	anim_player.seek(seek, true)
	timer.start(MAX_TIME)
	.enter()


func update(delta: float):
	var fdelta := delta * global.TARGET_FPS
	
	if _player:
		line_of_sight.cast_to = (_player.center.global_position - owner.global_position) * 2
		line_of_sight.force_raycast_update()
		if line_of_sight.get_collider() == _player:
			velocity = velocity.move_toward(Vector2.ZERO, fdelta * FRICTION)
			.update(delta)
			if velocity.length() < 0.05:
				emit_signal("state_change", "Attack", _player)
			return
	
	if timer.time_left <= 0:
		velocity = velocity.move_toward(Vector2.ZERO, fdelta * FRICTION)
		.update(delta)
		if velocity.length() < 0.05:
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
	if velocity.length() < 0.01:
		emit_signal("state_change", "Idle")


func _on_PlayerDetection_body_entered(body: Node):
	if body.is_in_group("player"):
		_player = body


func _on_PlayerDetection_body_exited(body: Node):
	if body.is_in_group("player"):
		_player = null

