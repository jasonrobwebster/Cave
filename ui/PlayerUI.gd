extends Control

var _max_health: int setget set_maxhealth
var _health: int setget set_health


func _ready():
	PlayerStats.connect("health_changed", self, "set_health")
	PlayerStats.connect("max_health_changed", self, "set_maxhealth")
	_max_health = PlayerStats.max_health
	_health = PlayerStats.health
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
