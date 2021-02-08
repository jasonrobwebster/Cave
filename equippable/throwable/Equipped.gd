extends "res://equippable/Equipped.gd"


func handle_input(event: InputEvent):
	if event.is_action_pressed("throw"):
		if event is InputEventMouseButton:
			var thrown_to = owner.get_global_mouse_position()
			emit_signal("state_change", "Unequipped", thrown_to)
