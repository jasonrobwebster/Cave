extends Control

export(NodePath) var player

var _max_health: int setget set_maxhealth
var _health: int setget set_health


func _ready():
	if player:
		set_player(player)


func set_player(value: NodePath):
	var player_node = get_node(value)
	player = value
	_max_health = player_node.max_health
	_health = player_node.health
	player_node.connect("health_changed", self, "set_health")
	player_node.connect("max_health_changed", self, "set_maxhealth")
	_update_text()


func set_maxhealth(value: int):
	_max_health = max(1, value)
	if _health:
		self._health = _health
	_update_text()
	

func set_health(value: int):
	_health = clamp(value, 0, _max_health)
	_update_text()


func _update_text():
	$Label.text = "HP: {0}/{1}".format([_health, _max_health])
