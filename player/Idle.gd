extends "res://player/OnGround.gd"


func enter(_previous_state: String = '', _args=null):
	anim_player.play("Idle")
	_snap = true


func update(delta):
	var input_x := _get_input_x()
	if input_x != 0:
		emit_signal("state_change", "Move")
	.update(delta)


func handle_input(event: InputEvent):
	if event.is_action_pressed("interact"):
		_handle_interaction()
	.handle_input(event)


func _handle_interaction():
	var bodies: Array = interact_zone.get_overlapping_bodies()
	if not bodies:
		return
	
	# find closest body
	var min_dist := 100000.0
	var min_body: Node
	for body in bodies:
		var dist: float = owner.global_position.distance_to(body.global_position)
		if dist >= min_dist:
			continue
		min_dist = dist
		min_body = body
	
	emit_signal("state_change", "CarryIdle", min_body)
