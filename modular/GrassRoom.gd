extends Node2D
class_name ModularRooms

enum Type {R, L, LR, LRT, LRB, LRBT, Empty}

export(Vector2) var room_size

var _rng = RandomNumberGenerator.new()


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
