extends "res://enemies/bat/BatState.gd"

const CHARGE_TIME := 1.0
const MAX_TIME := 5.0
const ACCELERATION := 30
const FRICTION := 2.5
const MAX_SPEED := 120

var _target_pos: Vector2 = Vector2.ZERO
var _player: Node = null
var _charging = true


onready var timer: Timer = $ChargeTimer
onready var maxtimer: Timer = $MaxTimer


func enter(previous_state: String = '', player: Node = null):
	_player = player
	pivot.scale.x = sign(_player.global_position.x - owner.global_position.x)
	_charging = true
	if not _player:
		emit_signal("state_change", previous_state if previous_state != "Attack" else "Idle")
		return
	anim_player.play("Attack")
	player_detection.set_deferred("monitoring", false)
	timer.start(CHARGE_TIME)
	maxtimer.start(MAX_TIME)
	maxtimer.connect("timeout", self, "_on_MaxTimer_timeout")


func exit():
	velocity = Vector2.ZERO
	maxtimer.disconnect("timeout", self, "_on_MaxTimer_timeout")
	player_detection.monitoring = true


func update(delta: float):
	if timer.time_left > 0:
		_target_pos = _player.head.global_position
		line_of_sight.cast_to = (_player.center.global_position - owner.global_position) * 2
		line_of_sight.force_raycast_update()
		if !line_of_sight.is_colliding():
			emit_signal("state_change", "Idle")
		if line_of_sight.get_collider() != _player:
			emit_signal("state_change", "Idle")
		return
	
	var fdelta := delta * global.TARGET_FPS
	var move: Vector2 = _target_pos - owner.global_position
	
	if _charging and move.length() < 5:
		_charging = false
	
	if _charging:
		velocity = velocity.move_toward(
			move.normalized() * MAX_SPEED,
			ACCELERATION * fdelta
		)
	else:
		velocity = velocity.move_toward(
			Vector2.ZERO,
			FRICTION * fdelta
		)
	
	if !_charging and velocity.length() < 0.05:
		emit_signal("state_change", "Recover", _target_pos)
	.update(delta)


func _on_MaxTimer_timeout():
	if !active:
		return
	emit_signal("state_change", "Idle")


func _on_PlayerChase_body_exited(body: Node):
	if body.is_in_group("player") and active:
		emit_signal("state_change", "Idle")
