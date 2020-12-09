extends "res://enemies/snake/SnakeState.gd"

const WANDER_CHANCE := 0.9
const INIT_TIME := 2
const EXTEND_TIME := 0.25

onready var timer: Timer = $Timer


func enter(_previous_state: String = '', _args = null):
	anim_player.play("Idle")
	timer.start(INIT_TIME)
	pass


func exit():
	# state cleanup
	pass


func update(_delta):
	# called during _physics_process
	pass


func handle_input(_event):
	# called during _unhandled_input
	pass


func _on_Timer_timeout():
	if !active:
		return
	if _rng.randf() > WANDER_CHANCE:
		timer.start(EXTEND_TIME)
		return
	emit_signal("state_change", "Wander")
