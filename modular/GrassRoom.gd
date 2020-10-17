extends Node2D
class_name ModularRooms

enum Type {R, L, LR, LRT, LRB, LRBT, Empty}

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


func get_class():
	return "ModularRooms"


func get_room_info(type: int) -> Dictionary:
	var room_info: Dictionary = {"objects": [], "level": null, "bg": null}
	var room_dir := get_child(type)
	var index: int = _rng.randi_range(0, room_dir.get_child_count()-1)
	var room_node := room_dir.get_child(index)
	var level_tilemap: TileMap = room_node.get_node_or_null("Level")
	var bg_tilemap: TileMap = room_node.get_node_or_null("Background")
	
	room_info.level  = level_tilemap
	room_info.bg = bg_tilemap
	
	for child in room_node.get_children():
		if child == level_tilemap or child == bg_tilemap:
			continue
		room_info.objects.push_back(child)
	
	return room_info
