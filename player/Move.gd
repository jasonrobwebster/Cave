extends "res://player/OnGround.gd"

func _ready():
	connect("start_run", self, "_on_self_start_run")
	connect("end_run", self, "_on_self_end_run")


func enter(previous_state: String = '', v = Vector2.ZERO):
	velocity = v
	if Input.is_action_pressed("run"):
		anim_player.play("Run")
	else:
		anim_player.play("Walk")
	_snap = true


func update(delta):
	if not owner.is_on_floor():
		coyote_timer.start(COYOTE_TIME)
		emit_signal("state_change", "Fall", velocity)
	_calculate_velocity(delta, ACCELRATION, FRICTION)
	if velocity.is_equal_approx(Vector2.ZERO) and _get_input_x() == 0:
		emit_signal("state_change", "Idle")
	.update(delta)

func _on_self_start_run():
	var cur_pos := anim_player.current_animation_position
	anim_player.play("Run")
	anim_player.seek(cur_pos, true)

func _on_self_end_run():
	var cur_pos := anim_player.current_animation_position
	anim_player.play("Walk")
	anim_player.seek(cur_pos, true)
