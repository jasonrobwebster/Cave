extends "res://equippable/Equipped.gd"


func handle_input(event: InputEvent):
	if event.is_action_pressed("use"):
		if event is InputEventMouseButton:
			var pos = owner.get_global_mouse_position()
			emit_signal("state_change", "Unequipped", pos)
