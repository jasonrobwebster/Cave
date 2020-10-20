class_name State
extends Node
# defines a basic state structure
# meant to be extended by other nodes

# warning-ignore:unused_signal
signal state_change(next_state, args)


func enter(args = null):
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
