extends Node

signal max_health_changed(new_value)
signal health_changed(new_value)

export(int) var max_health = 5 setget set_maxhealth
export(int) var health = 5 setget set_health


func set_health(value: int):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)


func set_maxhealth(value: int):
	max_health = max(1, value)
	if health:
		self.health = health
	emit_signal("max_health_changed", max_health)
