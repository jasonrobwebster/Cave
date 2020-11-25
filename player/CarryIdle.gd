extends "res://player/Carry.gd"


func enter(previous_state: String = '', item: RigidBody2D=null):
	anim_player.play("CarryIdle")
	if item:
		emit_signal("pickup_item", item, item.get_parent())


func update(delta):
	var input_x := _get_input_x()
	if input_x != 0:
		emit_signal("state_change", "CarryWalk")
	.update(delta)


func handle_input(event: InputEvent):
	if event.is_action_pressed("interact"):
		_throw(Vector2(sign(pivot.scale.x) * THROW_HSPEED, THROW_VSPEED))
		emit_signal("state_change", "CarryThrow")
