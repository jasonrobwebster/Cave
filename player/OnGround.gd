extends "res://player/Motion.gd"

const ACCELRATION := 25
const FRICTION := 25

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		emit_signal("state_change", "Jump", velocity + global.up_direction * JUMP_FORCE)
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
	
	if carry_pivot.get_child_count() > 0:
		carry_pivot.get_child(0).unequip()
	min_body.equip(carry_pivot)
#	emit_signal("state_change", "CarryIdle", min_body)
