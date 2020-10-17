class_name ActionSpace
extends Resource

var _actions: Dictionary setget _set_action_space
var _init_actions: Dictionary
var _size: int setget ,size
var _rng := RandomNumberGenerator.new()


func _init(moves: Array, weights: Array, mask: Array):
	self._actions = {
		"moves": moves,
		"weights": weights,
		"mask": mask,
	}
	self._init_actions = _actions


func _set_action_space(value):
	var moves: Array = value.moves
	var weights: Array = value.weights
	var mask: Array = value.mask
	var arrays := [moves, weights, mask]
	for arr_i in range(arrays.size()):
		for arr_j in range(arr_i+1, arrays.size()):
			assert(
				arrays[arr_i].size() == arrays[arr_j].size(),
				"ERROR: Mismatched array lengths when setting action space"
			)
	_actions = {
		"moves": moves,
		"weights": weights,
		"mask": mask,
	}
	_size = moves.size()


func size():
	return _size

func choose_action():
	var move_probability := []
	var move_sum := 0.0
	for i in range(_size):
		move_probability.push_back(_actions.weights[i] * _actions.mask[i])
		move_sum += _actions.weights[i] * _actions.mask[i]
	
	var rand_idx := 0
	var choice := _rng.randf() * move_sum
	var move_cdf: float = move_probability[0]
	while choice > move_cdf:
		rand_idx += 1
		move_cdf += move_probability[rand_idx]
	
	return _actions.moves[rand_idx]


func set_mask(mask: Array) -> void:
	var moves: Array = _actions.moves
	var weights: Array = _actions.weights
	self._actions = {
		"moves": moves,
		"weights": weights,
		"mask": mask,
	}


func _reset_action_space() -> void:
	self._actions = _init_actions
