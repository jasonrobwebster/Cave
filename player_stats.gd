extends Node

signal max_health_changed(new_value)
signal health_changed(new_value)
signal equip_changed(new_texture)

export(int) var max_health = 5 setget set_maxhealth
export(int) var health = 5 setget set_health
export(Texture) var equip_texture = null setget set_equip
export(NodePath) var player_path = null setget set_playerpath

var player: Node2D = null setget ,get_player


func set_health(value: int):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)


func set_maxhealth(value: int):
	var diff: int = value - max_health
	max_health = max(1, value)
	if health:
		self.health = health + diff if diff > 0 else health
	emit_signal("max_health_changed", max_health)


func set_equip(value: Texture):
	equip_texture = value
	emit_signal("equip_changed", value)


func set_playerpath(value: NodePath):
	player_path = value
	if value:
		player = get_node_or_null(player_path)


func get_player():
	return player
