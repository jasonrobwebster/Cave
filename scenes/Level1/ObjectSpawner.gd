extends Node2D


export(float, 0, 1) var path_room_spawn_multiplier = 1
export(float, 0, 1) var treasure_room_spawn_multiplier = 1
export(Array, PackedScene) var ground_enemies = []
export(Array, PackedScene) var rooftop_enemies = []
export(Array, PackedScene) var wall_enemies = []
export(Array, PackedScene) var flying_enemies = []
export(Array, PackedScene) var treasures = []

enum Placement {
	FLOOR, WALL, ROOF, AIR
}

const SPAWN_CHANCE_DEFAULT := 0.1

var find_collision := false
var printing := true

var _path: PoolVector2Array
var _treasure: PoolVector2Array
var _player_room: Vector2
var _room_size: Vector2
var _tile_size: Vector2
var _rng = RandomNumberGenerator.new()


func _ready():
	_rng.randomize()


func _place_enemies():
	var empty_points := _find_empty_worldvs()
	var ground_points := _find_empty_ground_worldvs(empty_points)
	var rooftop_points := _find_empty_rooftop_worldvs(empty_points)
	var wall_points := _find_empty_wall_worldvs(empty_points)
	var air_points := _find_empty_air_worldvs(empty_points)
	_spawn_enemies(ground_enemies, ground_points, Placement.FLOOR)
	_spawn_enemies(rooftop_enemies, rooftop_points)
	_spawn_enemies(wall_enemies, wall_points)
	_spawn_enemies(flying_enemies, air_points)
	_place_treasures(treasures, ground_points, empty_points)


func _spawn_enemies(
	enemies: Array, 
	points: Array,
	placement: int = Placement.AIR
):
	var place_offset_map := {
		Placement.AIR: Vector2.ZERO,
		Placement.FLOOR: _tile_size.project(Vector2.UP) / 2,
		Placement.WALL: Vector2.ZERO,
	}
	var place_offset = place_offset_map[placement]
	if not enemies:
		return
	for point in points:
		if _worldv_to_roomv(point) == _player_room:
			continue
		var spawn_mult := _get_spawn_multiplier(point)
		var enemy = enemies[_rng.randi() % len(enemies)].instance()
		var spawn_chance = enemy.get("spawn_chance")
		if not spawn_chance:
			spawn_chance = SPAWN_CHANCE_DEFAULT
		if _rng.randf() > spawn_chance * spawn_mult:
			enemy.queue_free()
			continue
		enemy.global_position = point + place_offset
		add_child(enemy)


func _place_treasures(treasures: Array, points: Array, empty_points: Array):
	if not treasures:
		return
	for point in points:
		if _worldv_to_roomv(point) == _player_room:
			continue
		var spawn_mult := _get_spawn_multiplier(point)
		var treasure = treasures[_rng.randi() % len(treasures)].instance()
		var spawn_chance = treasure.get("spawn_chance")
		if not spawn_chance:
			spawn_chance = SPAWN_CHANCE_DEFAULT
		var surrounding_empty := _count_surrounding_empty_points(point, empty_points)
		var surrounding_fill := 4 - surrounding_empty - 1
		var proportion_fill := surrounding_fill / 3
		print(proportion_fill, " ", spawn_chance * spawn_mult * proportion_fill)
		if _rng.randf() > spawn_chance * spawn_mult * proportion_fill:
			treasure.queue_free()
			continue
		treasure.global_position = point + _tile_size.project(Vector2.UP) / 2
		add_child(treasure)


func _get_spawn_multiplier(worldv: Vector2) -> float:
	var spawn_mult: float = path_room_spawn_multiplier
	if _worldv_to_roomv(worldv) in _treasure:
		spawn_mult = treasure_room_spawn_multiplier
	return spawn_mult


func _count_surrounding_empty_points(point: Vector2, empty_points: Array) -> float:
	var out: float = 0.0
	for offset in [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]:
		var point_offset = point + _tilev_to_worldv(offset)
		if point_offset in empty_points:
			out += 1.0
	return out


func _find_empty_worldvs() -> PoolVector2Array:
	var out: PoolVector2Array = []
	var space_state = get_world_2d().get_direct_space_state()
	var room_tilevs := _get_room_tilevs()
	
	for roomv in _path:
		var room_offset = _roomv_to_worldv(roomv)
		for tilev in room_tilevs:
			var tile_offset = _tilev_to_worldv(tilev)
			var worldv = room_offset + tile_offset + _tile_size/2
			var result = space_state.intersect_point(worldv, 32, [], 1, true)
			if result:
				continue
			out.push_back(worldv)
	
	for roomv in _treasure:
		var room_offset = _roomv_to_worldv(roomv)
		for tilev in room_tilevs:
			var tile_offset = _tilev_to_worldv(tilev)
			var worldv = room_offset + tile_offset + _tile_size/2
			var result = space_state.intersect_point(worldv, 32, [], 1, true)
			if result:
				continue
			out.push_back(worldv)
	
	return out


func _find_empty_ground_worldvs(empty_points: PoolVector2Array) -> Array:
	var out := []
	for point in empty_points:
		if point + _tile_size.project(Vector2.UP) in empty_points:
			continue
		out.push_back(point)
	return out


func _find_empty_rooftop_worldvs(empty_points: PoolVector2Array) -> Array:
	var out := []
	for point in empty_points:
		if not point + _tile_size.project(Vector2.UP) in empty_points:
			continue
		if point - _tile_size.project(Vector2.UP) in empty_points:
			continue
		out.push_back(point)
	return out


func _find_empty_wall_worldvs(empty_points: PoolVector2Array) -> Array:
	var out := []
	for point in empty_points:
		if (
			(point + _tile_size.project(Vector2.RIGHT) in empty_points)
			and (point - _tile_size.project(Vector2.RIGHT) in empty_points)
		):
			continue
		if not point + _tile_size.project(Vector2.UP) in empty_points:
			continue
		if not point - _tile_size.project(Vector2.UP) in empty_points:
			continue
		out.push_back(point)
	return out


func _find_empty_air_worldvs(empty_points: PoolVector2Array) -> Array:
	var out := []
	for point in empty_points:
		if not (
			(point + _tile_size.project(Vector2.RIGHT) in empty_points)
			and (point - _tile_size.project(Vector2.RIGHT) in empty_points)
			and (point + _tile_size.project(Vector2.UP) in empty_points)
			and (point - _tile_size.project(Vector2.UP) in empty_points)
		):
			continue
		out.push_back(point)
	return out


func _get_room_tilevs() -> PoolVector2Array:
	var tilevs: PoolVector2Array = []
	for x in range(_room_size.x):
		for y in range(_room_size.y):
			tilevs.push_back(Vector2(x, y))
	return tilevs


func _worldv_to_roomv(worldv: Vector2) -> Vector2:
	return (worldv / _tile_size / _room_size).floor()

func _worldv_to_tilev(worldv: Vector2) -> Vector2:
	return (worldv / _tile_size).floor()

func _tilev_to_roomv(gridv: Vector2) -> Vector2:
	return (gridv / _room_size).floor()

func _tilev_to_worldv(tilev: Vector2) -> Vector2:
	return tilev * _tile_size

func _roomv_to_tilev(roomv: Vector2) -> Vector2:
	return roomv * _room_size

func _roomv_to_worldv(roomv: Vector2) -> Vector2:
	return roomv * _room_size * _tile_size


func _on_RandomRoomWalker_level_finalised(
	path_rooms, 
	treasure_rooms,
	player_room, 
	room_size,
	tile_size
):
	_path = path_rooms
	_treasure = treasure_rooms
	_player_room = player_room
	_room_size = room_size
	_tile_size = tile_size
	
	# Have to pause a short bit to allow the tilemap collision areas to 
	# update. This somehow (?) solves that problem.
	yield(get_tree().create_timer(0), "timeout")
	_place_enemies()
	
