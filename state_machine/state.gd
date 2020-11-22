class_name State
extends Node
# defines a basic state structure
# meant to be extended by other nodes

var active := true setget set_active

# warning-ignore:unused_signal
signal state_change(next_state, args)


func enter(_previous_state: String = '', _args = null):
	# handle entering state
	pass


func exit():
	# state cleanup
	pass


func update(_delta):
	# called during _physics_process
	pass


func handle_input(_event):
	# called during _unhandled_input
	pass


func set_active(value: bool):
	active = value
	set_physics_process(value)
	set_process_input(value)
