class_name StateMachine
extends Node
# basic state machine
# used as a root node to define a finite state machine
# children are treated as states and are automatically assigned
# to the state_map dictionary

signal state_change(new_state)

export(NodePath) var start_state

var state_map: Dictionary = {}
var current_state: State = null
var active := false setget set_active


func _ready():
	if not start_state:
		start_state = get_child(0).get_path()
	for child in get_children():
		child.connect("state_change", self, "_change_state")
	initialise(start_state)


func initialise(start_path: NodePath):
	set_active(true)
	_assign_state_map()
	current_state = get_node(start_path)
	current_state.enter()


func _physics_process(delta):
	current_state.update(delta)


func _unhandled_input(event):
	current_state.handle_input(event)


func set_active(value: bool):
	active = value
	set_physics_process(value)
	set_process_input(value)
	if not active:
		current_state = null


func _assign_state_map():
	state_map = {}
	for child in get_children():
		state_map[child.name] = child


func _change_state(state_name):
	if not active:
		return
	current_state.exit()
	current_state = state_map[state_name]
	current_state.enter()
	emit_signal("state_change", current_state)
	
