extends Node2D
class_name RandomRoomWalker

export(PackedScene) var ModularScene
export(Vector2) var bbox = Vector2(4, 3)

var start_room: Vector2
var player_room: Vector2
var end_room: Vector2
var path := []
var moves := []

var _empty_rooms := []
var _action_mask := [1, 1, 1]
var _action_space := ActionSpace.new(
	[Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT],
	[3, 1, 3],
	_action_mask
)
var _room_mask := [0, 0, 0, 0, 0, 0, 0]
var _player_reached := false
var _end_reached := false
var _rng := RandomNumberGenerator.new()
var _player: Node2D = null

onready var _rooms: ModularRooms = ModularScene.instance()
onready var _room_space := ActionSpace.new(
	_rooms.Type.values(),
	[1, 1, 5, 3, 3, 2, 0],
	_room_mask
)

signal level_finished


func _ready():
	_rng.randomize()
	connect("level_finished", $Level, "_build_tilemap_from_random_cells")
	if _rooms.get_class() != "ModularRooms":
		push_warning("variable 'Rooms' should be a 'ModularRooms' class")
	_generate_level()


func _generate_level():
	_reset()
	while !_end_reached:
		_walk()
	_place_rooms()
	_place_walls()
	_fill_empty()
	emit_signal("level_finished")


func _reset():
	start_room = Vector2(_rng.randi_range(0, bbox.x), 0)
	player_room = Vector2(_rng.randi_range(0, bbox.x), 0)
	end_room = Vector2(_rng.randi_range(0, bbox.x), bbox.y)
	path = [start_room]
	moves = []
	_player_reached = (start_room == player_room)
	_end_reached = false
	_empty_rooms = []
	for x in range(bbox.x+1):
		for y in range(bbox.y+1):
			_empty_rooms.push_back(Vector2(x, y))
	_empty_rooms.erase(start_room)


func _walk():
	var action_mask: Array = _action_mask.duplicate()
	if !moves.empty():
		var last_move: Vector2 = moves.back()
		match last_move:
			Vector2.LEFT:
				action_mask[2] = 0
			Vector2.RIGHT:
				action_mask[0] = 0
	
	var current_position: Vector2 = path.back()
	if current_position.y == bbox.y:
		action_mask[1] = 0
	if current_position.x == 0:
		action_mask[0] = 0
	if current_position.x == bbox.x:
		action_mask[2] = 0
	
	_action_space.set_mask(action_mask)
	var move: Vector2 = _action_space.choose_action()
	
	if current_position.y == 0 and !_player_reached:
		move = (player_room - current_position).normalized()
	if current_position.y == bbox.y and !_end_reached:
		move = (end_room - current_position).normalized()
	
	var next_position: Vector2 = current_position + move
	if next_position == player_room:
		_player_reached = true
	if next_position == end_room:
		_end_reached = true
	
	moves.push_back(move)
	path.push_back(next_position)
	_empty_rooms.erase(next_position)


func _place_rooms():
	for i in range(path.size()):
		var gridv: Vector2 = path[i]
		var incoming: Vector2 = Vector2.ZERO if i == 0 else moves[i - 1]
		var outgoing: Vector2 = Vector2.ZERO if i >= moves.size() else moves[i]
		_place_room(gridv, [incoming], [outgoing])


func _place_walls():
	var x_right = _grid_to_tile_map(bbox).x + _rooms.room_size.x
	var y_bottom = _grid_to_tile_map(bbox).y + _rooms.room_size.y
	
	# fill top & bottom
	for y in range(-2, 0):
		for x in range(-2, x_right + 2):
			var top_v := Vector2(x, y)
			var bot_v := Vector2(x, y_bottom - y - 1)
			$Level.set_cellv(top_v, _rooms.wall_id)
			$Level.set_cellv(bot_v, _rooms.wall_id)
	
	# fill left & right
	for y in range(0, y_bottom):
		for x in range(-2, 0):
			var left_v := Vector2(x, y)
			var right_v := Vector2(x_right - x - 1, y)
			$Level.set_cellv(left_v, _rooms.wall_id)
			$Level.set_cellv(right_v, _rooms.wall_id)


func _fill_empty():
	print(_empty_rooms)
	for roomv in _empty_rooms:
		_place_room(roomv)


func _place_room(gridv: Vector2, incoming := [], outgoing := []):
	var tile_offset: Vector2 = _grid_to_tile_map(gridv)
	var obj_offset: Vector2 = _grid_to_world_map(gridv)
	var in_player_room: bool = gridv == player_room
	
	var room_info = _get_valid_room(incoming, outgoing, in_player_room)
	
	var rm_level: TileMap = room_info.level
	if rm_level:
		for v in rm_level.get_used_cells():
			$Level.set_cellv(v + tile_offset, rm_level.get_cellv(v))
	
#	var rm_bg: TileMap = room_info.bg
#	if rm_bg:
#		for v in rm_bg.get_used_cells():
#			$Background.set_cellv(v + tile_offset, rm_level.get_cellv(v))
	
	for obj in room_info.objects:
		if obj.is_in_group("player"):
			if !in_player_room:
				continue
			_player = obj.duplicate()
			_player.global_position += obj_offset
			$Objects.add_child(_player)
			continue
		elif obj.is_in_group("enemy") and in_player_room:
			continue
		var child: Node2D = obj.duplicate()
		child.global_position += obj_offset
		$Objects.add_child(child)


func _get_valid_room(incoming: Array, outgoing: Array, 
in_player_room: bool) -> Dictionary:
	var mask := _room_mask.duplicate()
	var valid_types = _rooms.get_valid_types(incoming, outgoing, in_player_room)
	
	for type in valid_types:
		mask[type] = 1	
	_room_space.set_mask(mask)
	
	var room_type: int = _room_space.choose_action()
	var room_info := _rooms.get_room_info(room_type, in_player_room)
	
	return room_info


func _grid_to_tile_map(gridv: Vector2) -> Vector2:
	return gridv * _rooms.room_size
	
func _grid_to_world_map(gridv: Vector2) -> Vector2:
	return gridv * _rooms.room_size * _rooms.tile_size
