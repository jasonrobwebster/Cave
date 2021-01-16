extends "res://enemies/bat/BatState.gd"

const WANDER_CHANCE := 0.8
const INIT_TIME := 1.0
const EXTEND_TIME := 0.5

var _player: Node = null

onready var timer: Timer = $Timer


func enter(_previous_state: String = '', _args=null):
	var seek := 0.0
	if _previous_state == 'Wander':
		seek = anim_player.current_animation_position
	anim_player.play("Idle")
	anim_player.seek(seek, true)
	timer.start(INIT_TIME)


func update(_delta):
	if timer.time_left > 0:
		return
	if _player:
		line_of_sight.cast_to = (_player.center.global_position - owner.global_position) * 2
		line_of_sight.force_raycast_update()
		if line_of_sight.get_collider() == _player:
			emit_signal("state_change", "Attack", _player)
			return
	if _rng.randf() > WANDER_CHANCE:
		timer.start(EXTEND_TIME)
		return
	emit_signal("state_change", "Wander")


func _on_PlayerDetection_body_entered(body: Node):
	if body.is_in_group("player"):
		_player = body


func _on_PlayerDetection_body_exited(body: Node):
	if body.is_in_group("player"):
		_player = null
