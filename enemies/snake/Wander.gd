extends "res://enemies/snake/SnakeState.gd"

const MAX_SPEED := 30
const ACCELERATION := 15
const INIT_TIME := 2
const EXTEND_TIME := 1
const IDLE_CHANCE := 0

var _direction = 1

onready var timer: Timer = $Timer


func enter(_previous_state: String = '', _args = null):
	# handle entering state
	_direction = sign(pivot.scale.x)
	timer.start(INIT_TIME)
	anim_player.play("Slither")


func exit():
	# state cleanup
	pass


func update(delta: float):
	var fdelta := delta * global.TARGET_FPS
	_direction = _detect_wall(_direction, fdelta)
	_direction = _detect_floor(_direction)
	velocity.x = move_toward(
		velocity.x,
		MAX_SPEED * _direction,
		fdelta * ACCELERATION
	)
	.update(delta)


func handle_input(_event):
	# called during _unhandled_input
	pass


func _detect_wall(direction: int, fdelta: float) -> int:
	wall_ray.cast_to.x = max(abs(velocity.x / (fdelta * ACCELERATION)) / 2, 0.5)
	wall_ray.force_raycast_update()
	if wall_ray.is_colliding() and direction != -sign(pivot.scale.x):
		direction = -sign(pivot.scale.x)
	return direction


func _detect_floor(direction: int) -> int:
	if !floor_ray.is_colliding() and direction != -sign(pivot.scale.x):
		direction = -sign(pivot.scale.x)
	return direction


func _on_Timer_timeout():
	if !active:
		return
	if _rng.randf() > IDLE_CHANCE:
		timer.start(EXTEND_TIME)
		return
	emit_signal("state_change", "Idle")
