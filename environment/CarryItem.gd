extends RigidBody2D

export(Vector2) var pickup_offset = Vector2(0, -3)

const MAX_HSPEED := 400
const MAX_VSPEED := 400


func _integrate_forces(state):
	var lv := linear_velocity
	lv.x = clamp(lv.x, -MAX_HSPEED, MAX_HSPEED)
	lv.y = clamp(lv.y, -MAX_VSPEED, MAX_VSPEED)
