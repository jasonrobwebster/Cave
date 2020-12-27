extends "res://equippable/State.gd"


func enter(_previous_state: String = '', args = null):
	# handle entering state
	pass


func exit():
	# state cleanup
	pass


func update(delta):
	.update(delta)


func handle_input(_event: InputEvent):
	pass
