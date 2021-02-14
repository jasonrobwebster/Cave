extends "res://player/Motion.gd"

const ACCELRATION := 25
const FRICTION := 25

func handle_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		emit_signal("state_change", "Jump", velocity + global.up_direction * JUMP_FORCE)
	if event.is_action_pressed("pickup"):
		_handle_pickup()
	if event.is_action_pressed("interact"):
		_handle_interaction()
	.handle_input(event)


func _handle_pickup():
	var bodies: Array = equippable_zone.get_overlapping_bodies()
	
	# find closest body
	var min_dist := 100000.0
	var min_body: Node
	for body in bodies:
		if body == PlayerStats.get_child(0):
			continue
		if not body.can_equip:
			continue
		var dist: float = owner.global_position.distance_to(body.global_position)
		if dist >= min_dist:
			continue
		min_dist = dist
		min_body = body
	
	if PlayerStats.get_child_count() > 0:
		PlayerStats.get_child(0).unequip()
	if not min_body:
		return
	min_body.equip()
#	emit_signal("state_change", "CarryIdle", min_body)


func _handle_interaction():
	var areas: Array = interact_zone.get_overlapping_areas()
	if not areas:
		return
	
	# find closest body
	var min_dist := 100000.0
	var min_area: Node
	for area in areas:
		var dist: float = owner.global_position.distance_to(area.global_position)
		if dist >= min_dist:
			continue
		min_dist = dist
		min_area = area
	
	if not min_area:
		return
	min_area.interact()
#	emit_signal("state_change", "CarryIdle", min_body)
