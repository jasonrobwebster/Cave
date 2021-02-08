extends "res://equippable/State.gd"

export(Vector2) var pickup_offset = Vector2.ZERO
export(Texture) var UI_texture

var _prev_parent: Node
var _parent: Node


func enter(_previous_state: String = '', _args = null):
	sprite.visible = false
	PlayerStats.equip_texture = UI_texture
	owner.get_parent().remove_child(owner)
	PlayerStats.add_child(owner)
	owner.position = pickup_offset


func exit():
	sprite.visible = true
	PlayerStats.equip_texture = null
	var root = get_tree().get_root()
	PlayerStats.remove_child(owner)
	root.add_child(owner)
	owner.global_position = PlayerStats.player.carry_pivot.global_position + pickup_offset


func update(_delta):
	# called during _physics_process
	pass


func handle_input(event: InputEvent):
	.handle_input(event)
