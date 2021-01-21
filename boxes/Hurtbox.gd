class_name Hurtbox
extends Area2D

export(float, 0, 2) var invincible_time = 0.5

var invincible := false setget set_invincibility

signal invincibility_started()
signal invincibility_ended()
signal Hurt(area)


func set_invincibility(value: bool):
	invincible = value
	if value:
		emit_signal("invincibility_started")
		$InvincibilityTimer.start(invincible_time)
	else:
		emit_signal("invincibility_ended")


func _on_Timer_timeout():
	self.invincible = false


func _on_Hurtbox_area_entered(area: Hitbox):
	if not invincible:
		emit_signal("Hurt", area)
		self.invincible = true
