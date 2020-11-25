extends "res://player/Motion.gd"

signal pickup_item(item, parent)
signal drop_item()

const ACCELRATION := 15
const FRICTION := 30
const THROW_HSPEED = 150
const THROW_VSPEED = -100

var _carrying: RigidBody2D
var _carrying_parent: Node


func _ready():
	for child in get_parent().get_children():
		if not "Carry" in child.name:
			continue
		connect("pickup_item", child, "_on_PickupItem")
		connect("drop_item", child, "_on_DropItem")


func _on_PickupItem(item, parent):
	if not item and not _carrying:
		emit_signal("state_change", "Idle")
		return
	if item and _carrying and item != _carrying:
		_drop()
		_carrying = item
		_carrying_parent = parent
		pass
	if item and not _carrying:
		_carrying = item
		_carrying_parent = parent
	if not item and _carrying:
		return
	
	# handle the item
	_carrying_parent.remove_child(item)
	carry_pivot.add_child(item)
	var offset = item.get("pickup_offset")
	if not offset:
		offset = Vector2.ZERO
	item.position = offset
	item.mode = RigidBody2D.MODE_KINEMATIC


func _on_DropItem():
	_carrying = null
	_carrying_parent = null


func _drop():
	_throw(velocity)
	emit_signal("drop_item")


func _throw(throw_velocity: Vector2):
	carry_pivot.remove_child(_carrying)
	_carrying_parent.add_child(_carrying)
	var offset = _carrying.get("pickup_offset")
	if not offset:
		offset = Vector2.ZERO
	_carrying.global_position = carry_pivot.global_position + offset
	_carrying.mode = RigidBody2D.MODE_RIGID
	_carrying.linear_velocity = throw_velocity
