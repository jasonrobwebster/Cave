extends Node2D
class_name ModularRooms

enum Type {L, R, LR, LB, RB, LT, RT, LRT, LRB, LRBT}

export(Vector2) var room_size = Vector2(4, 4)
export(Vector2) var tile_size = Vector2(16, 16)
export(int) var wall_id

var _rng = RandomNumberGenerator.new()
var _player_rooms: Dictionary = {}


func _notification(what):
	if what == NOTIFICATION_INSTANCED:
		_get_player_rooms()


func _get_player_rooms():
	_reset_player_rooms()
	var room_dir: Node2D
	var room_node: Node2D
	# not a big fan of the three for loops, but this will work for now
	for room_type in Type.values():
		room_dir = get_child(room_type)
		for index in range(room_dir.get_child_count()):
			room_node = room_dir.get_child(index)
			for child in room_node.get_children():
				if child.is_in_group("player"):
					_player_rooms[room_type].push_back(index)
					break


func _reset_player_rooms():
	_player_rooms = {}
	for type in Type.values():
		_player_rooms[type] = []


func get_valid_types(incoming: Array, outgoing: Array, 
force_player: bool = false, allow_empty: bool = false) -> Array:
	var valid_types := Type.duplicate()
	
	for v in incoming:
		match v:
			Vector2.LEFT:
				_erase_direction_from_types(valid_types, 'R', false)
			Vector2.RIGHT:
				_erase_direction_from_types(valid_types, 'L', false)
			Vector2.UP:
				_erase_direction_from_types(valid_types, 'B', false)
			Vector2.DOWN:
				_erase_direction_from_types(valid_types, 'T', false)
				
	for v in outgoing:
		match v:
			Vector2.LEFT:
				_erase_direction_from_types(valid_types, 'L', false)
			Vector2.RIGHT:
				_erase_direction_from_types(valid_types, 'R', false)
			Vector2.UP:
				_erase_direction_from_types(valid_types, 'T', false)
			Vector2.DOWN:
				_erase_direction_from_types(valid_types, 'B', false)
	
	if force_player:
		for key in valid_types.keys():
			if _player_rooms[valid_types[key]].empty(): valid_types.erase(key)
	
#	if !allow_empty:
#		valid_types.erase(Type.Empty)
	
	return valid_types.values()


func get_class():
	return "ModularRooms"


func get_room_info(type: int, force_player: bool = false) -> Dictionary:
	var room_info: Dictionary = {"objects": [], "tilemaps": []}
	var room_dir := get_child(type)
	var index = _rng.randi_range(0, room_dir.get_child_count()-1)
	if force_player:
		var player_indexes = _player_rooms[type]
		index = player_indexes[_rng.randi() % player_indexes.size()]
	var room_node := room_dir.get_child(index)
	
	for child in room_node.get_children():
		if child is TileMap:
			room_info.tilemaps.push_back(child)
			continue
		room_info.objects.push_back(child)
	
	return room_info


func _erase_direction_from_types(types: Dictionary, dir: String, include: bool):
	for key in types.keys():
		if (dir in key) and include: 
			types.erase(key)
		if !(dir in key) and !include: 
			types.erase(key)
