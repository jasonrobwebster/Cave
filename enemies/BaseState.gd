class_name EnemyBaseState
extends State

const IMAGE_VBUFFER := 5

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var velocity: Vector2 = Vector2.ZERO


func _move():
	velocity = owner.move_and_slide(
		velocity
	)


func _update_pivot(pivot: Position2D):
	if velocity.x <= -IMAGE_VBUFFER:
		pivot.scale.x = -1
	elif velocity.x >= IMAGE_VBUFFER:
		pivot.scale.x = 1
