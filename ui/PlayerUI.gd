extends Control

var _max_health: int setget set_maxhealth
var _health: int setget set_health
var _score: int setget set_score


func _ready():
	PlayerStats.connect("health_changed", self, "set_health")
	PlayerStats.connect("max_health_changed", self, "set_maxhealth")
	PlayerStats.connect("score_changed", self, "set_score")
	PlayerStats.connect("equip_changed", self, "set_equip")
	_max_health = PlayerStats.max_health
	_health = PlayerStats.health
	_update_text()


func set_maxhealth(value: int):
	_max_health = value
	_update_text()
	

func set_health(value: int):
	_health = value
	_update_text()


func set_score(value: int):
	_score = value
	$Score.text = "Score: {0}".format([_score])


func set_equip(texture: Texture):
	$ColorRect/TextureRect.texture = texture


func _update_text():
	$HP.text = "HP: {0}/{1}".format([_health, _max_health])
