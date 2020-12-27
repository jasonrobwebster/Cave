extends "res://equippable/Unequiped.gd"

signal thrown_collision()

export(float) var THROW_SPEED = 300

var _thrown: bool = false
var _direction: Vector2

func enter(_previous_state: String = '', pos = null):
	if pos == null:
		_thrown = false
		return
	_thrown = true
	_direction = owner.global_position.direction_to(pos)
	velocity = Vector2.ZERO


func update(delta):
	if !_thrown:
		.update(delta)
		return
	if owner.get_slide_count() > 0:
		emit_signal("thrown_collision")
		return
	velocity = _direction * THROW_SPEED
	_move()
