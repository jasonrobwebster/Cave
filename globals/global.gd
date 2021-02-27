extends Node

const TARGET_FPS: int = 60
const PIXELS_PER_METER: int = 32

var gravity = 25.0 * PIXELS_PER_METER / TARGET_FPS
var up_direction = Vector2.UP

var level: int = 0

func set_level(value):
	level = value
