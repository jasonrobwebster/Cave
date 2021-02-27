extends Node2D
class_name RandomRoomWalker

signal level_finished()
signal player_placed(player_path)
signal objects_placed()
signal tiles_placed()

export(float, 0, 1) var enemy_spawn_multiplier = 1
export(NodePath) var background_path
export(NodePath) var walls_path
export(PackedScene) var ModularScene
export(Vector2) var bbox = Vector2(4, 3)

const WALL_THICKNESS := 10

var start_room: Vector2
var player_room: Vector2
var end_room: Vector2
var path := []
var treasure := []
var moves := []

var _empty_rooms := []
var _action_mask := [1, 1, 1]
var _action_space := ActionSpace.new(
	[Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT],
	[3, 1, 3],
	_action_mask
)
var _room_mask := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var _player_reached := false
var _end_reached := false
var _rng := RandomNumberGenerator.new()
var _player: Node2D = null
var _tilemaps: Dictionary = {}
var _bg: TileMap = null
var _walls: TileMap = null
var _doorway = preload("res://interactable/doorways/Doorway.tscn")

onready var _rooms: ModularRooms = ModularScene.instance()
onready var _room_space := ActionSpace.new(
	_rooms.Type.values(),
	[1, 1, 3, 1, 1, 1, 1, 1, 1, 0.5],  #{L, R, LR, LB, RB, LT, RT, LRT, LRB, LRBT}
	_room_mask
)
onready var object_spawner := $ObjectSpawner


func _ready():
	_rng.randomize()
	if not background_path:
		background_path = get_child(0).get_path()
	if not walls_path:
		walls_path = get_child(1).get_path()
	
	_bg = get_node(background_path)
	_walls = get_node(walls_path)
	_tilemaps[_bg.name] = _bg
	_tilemaps[_walls.name] = _walls
	
	for tm in _tilemaps.values():
		connect("tiles_placed", tm, "_ready")
	
	if _rooms.get_class() != "ModularRooms":
		push_warning("variable 'Rooms' should be a 'ModularRooms' class")
	
	connect("level_finished", SceneManager, "_on_level_finished")
	
	_generate_level()


func _generate_level():
	_reset()
	while !_end_reached:
		_walk()
	_place_rooms()
	_place_walls()
	_place_background()
	_fill_empty()
	emit_signal("tiles_placed")
	_handle_objectspawn()
	yield(get_tree().create_timer(0.5), "timeout")
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
			Vector2.DOWN:
				action_mask[1] = 0
	
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
	for y in range(-WALL_THICKNESS, 0):
		for x in range(-WALL_THICKNESS, x_right + WALL_THICKNESS):
			var top_v := Vector2(x, y)
			var bot_v := Vector2(x, y_bottom - y - 1)
			_walls.set_cellv(top_v, _rooms.wall_id)
			_walls.set_cellv(bot_v, _rooms.wall_id)
	
	# fill left & right
	for y in range(0, y_bottom):
		for x in range(-WALL_THICKNESS, 0):
			var left_v := Vector2(x, y)
			var right_v := Vector2(x_right - x - 1, y)
			_walls.set_cellv(left_v, _rooms.wall_id)
			_walls.set_cellv(right_v, _rooms.wall_id)
	
	_walls.update_dirty_quadrants()


func _place_background():
	var x_right = _grid_to_tile_map(bbox).x + _rooms.room_size.x
	var y_bottom = _grid_to_tile_map(bbox).y + _rooms.room_size.y
	
	for x in range(-2, x_right + 2):
		for y in range(-2, y_bottom + 2):
			_bg.set_cell(x, y, 0, false, false, false, _get_subtile_coord(_bg, 0))


func _fill_empty():
	for roomv in _empty_rooms:
		_place_room(roomv)
		treasure.push_back(roomv)


func _handle_objectspawn():
	object_spawner.set_room_info(
		path.duplicate(),
		treasure.duplicate(),
		player_room,
		_rooms.room_size,
		_rooms.tile_size
	)
	# For some reason, particularly at this time, the Physics2DServer
	# hasn't caught on to the fact that tilemaps have been
	# placed with collision areas. Since the object spawner uses this internally
	# we opt to wait a frame (which, somehow, fixes this issue).
	yield(get_tree().create_timer(1/global.TARGET_FPS), "timeout")
	object_spawner.place_enemies()
	emit_signal("objects_placed")


func _place_room(gridv: Vector2, incoming := [], outgoing := []):
	var tile_offset: Vector2 = _grid_to_tile_map(gridv)
	var obj_offset: Vector2 = _grid_to_world_map(gridv)
	var in_player_room: bool = gridv == player_room
	
	var room_info = _get_valid_room(incoming, outgoing, in_player_room)
	
	var rm_tilemaps: Array = room_info.get("tilemaps", [])
	for tm in rm_tilemaps:
		_handle_tilemap(tm)
		for v in tm.get_used_cells():
			_tilemaps[tm.name].set_cellv(v + tile_offset, tm.get_cellv(v))
	
	for obj in room_info.objects:
		if obj.is_in_group("player"):
			if !in_player_room:
				continue
			_player = obj.duplicate()
			object_spawner.add_child(_player)
			_player.global_position += obj_offset
			var door = _doorway.instance()
			object_spawner.add_child(door)
			door.global_position = _player.global_position
			emit_signal("player_placed", _player.get_path())
			continue
		if obj.is_in_group("enemy"):
			if in_player_room:
				continue
			var enemy_spawn_chance: float = obj.get("spawn_chance")
			if not enemy_spawn_chance:
				enemy_spawn_chance = 1.0
			if not _rng.randf() <= enemy_spawn_chance * enemy_spawn_multiplier:
				continue
			
		var child: Node2D = obj.duplicate()
		object_spawner.add_child(child)
		child.global_position += obj_offset


func _handle_tilemap(tm: TileMap):
	if !(tm.name in _tilemaps.keys()):
		var child_tm: TileMap = tm.duplicate()
		child_tm.clear()
		add_child(child_tm)
		_tilemaps[tm.name] = child_tm
		connect("level_finished", child_tm, "_ready")


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


func _get_subtile_coord(tm: TileMap, cell_id: int):
	var tiles = tm.tile_set
	var rect = tiles.tile_get_region(cell_id)
	var x = randi() % int(rect.size.x / tiles.autotile_get_size(cell_id).x)
	var y = randi() % int(rect.size.y / tiles.autotile_get_size(cell_id).y)
	return Vector2(x, y)


func _grid_to_tile_map(gridv: Vector2) -> Vector2:
	return gridv * _rooms.room_size
	
func _grid_to_world_map(gridv: Vector2) -> Vector2:
	return gridv * _rooms.room_size * _rooms.tile_size
