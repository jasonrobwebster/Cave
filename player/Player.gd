extends KinematicBody2D

signal max_health_changed(new_value)
signal health_changed(new_value)

export(int) var max_health setget set_maxhealth

onready var health: int = max_health setget set_health


func _on_Hurtbox_area_entered(area: Hitbox):
	if area.get("damage"):
		self.health -= area.damage


func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)


func set_maxhealth(value):
	max_health = max(0, value)
	self.health = health
	emit_signal("max_health_changed", max_health)
