extends Node

const TARGET_FPS: int = 60
const PIXELS_PER_METER: int = 32
const LEVEL_PER_ROOM: int = 5

var gravity = 25.0 * PIXELS_PER_METER / TARGET_FPS
var up_direction = Vector2.UP

var level: int = 0 setget set_level
var room: int = 0 setget set_room

func set_level(value):
	level = value % LEVEL_PER_ROOM
	self.room = floor(value / LEVEL_PER_ROOM)


func set_room(value):
	room = value


func next_level() -> int:
	# checks what the next level will be and returns it
	var _lvl = level
	return (_lvl + 1) % LEVEL_PER_ROOM
