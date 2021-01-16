extends "res://equippable/State.gd"

export(Vector2) var pickup_offset = Vector2.ZERO
export(Texture) var UI_texture

var _prev_parent: Node
var _parent: Node


func enter(_previous_state: String = '', new_parent: Node2D = null):
	sprite.visible = false
	PlayerStats.equip_texture = UI_texture
	_prev_parent = owner.get_parent()
	_parent = new_parent
	
	_prev_parent.remove_child(owner)
	_parent.add_child(owner)
	owner.position = pickup_offset


func exit():
	sprite.visible = true
	PlayerStats.equip_texture = null
	_parent.remove_child(owner)
	_prev_parent.add_child(owner)
	owner.global_position = _parent.global_position + pickup_offset


func update(_delta):
	# called during _physics_process
	pass


func handle_input(event: InputEvent):
	.handle_input(event)
