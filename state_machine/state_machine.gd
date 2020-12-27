class_name StateMachine
extends Node
# basic state machine
# used as a root node to define a finite state machine
# children are treated as states and are automatically assigned
# to the state_map dictionary

signal state_change(new_state, previous_state)

export(NodePath) var start_state

var state_map: Dictionary = {}
var current_state: State = null
var active := false setget set_active


func _ready():
	if not start_state:
		start_state = get_child(0).get_path()
	for child in get_children():
		child.connect("state_change", self, "change_state")
	initialise(start_state)


func initialise(start_path: NodePath):
	set_active(true)
	_assign_state_map()
	_init_states()
	current_state = get_node(start_path)
	current_state.active = true
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


func _init_states():
	for child in get_children():
		child.active = false


func change_state(state_name, args = null):
	if not active:
		return
	if current_state == state_map[state_name]:
		return
	var previous_state: State = current_state
	previous_state.exit()
	current_state = state_map[state_name]
	
	previous_state.active = false
	current_state.active = true
	
	if args == null:
		current_state.enter(previous_state.name)
	else:
		current_state.enter(previous_state.name, args)
	emit_signal("state_change", current_state, previous_state)
	
