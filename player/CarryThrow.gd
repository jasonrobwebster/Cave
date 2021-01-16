extends "res://player/Carry.gd"


func enter(previous_state: String = '', throw_v: Vector2 = Vector2.ZERO):
	anim_player.play("CarryThrow")
	emit_signal("drop_item")


func _go_to_Idle_state():
	emit_signal("state_change", "Idle")
