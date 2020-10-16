extends Node2D
class_name RandomRoomWalker

export(PackedScene) var ModularScene
export(Vector2) var bbox = Vector2(4, 4)

var start_room: Vector2
var player_room: Vector2
var end_room: Vector2
var path := []
var moves := []


var _action_space := ActionSpace.new(
	[Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT],
	[3, 1, 3],
	[1, 1, 1]
)
var _player_reached = false
var _end_reached = false
var _rng = RandomNumberGenerator.new()

onready var rooms = ModularScene.instance()


func _ready():
	_rng.randomize()
	if rooms.get_class() != "ModularRooms":
		push_warning("variable 'Rooms' should be a 'ModularRooms' class")
	start_room = Vector2(_rng.randi_range(0, bbox.x), 0)
	player_room = Vector2(_rng.randi_range(0, bbox.x), 0)
	end_room = Vector2(_rng.randi_range(0, bbox.x), bbox.y)
	path = [start_room]
	print(player_room)
	print(end_room)
	if start_room == player_room:
		_player_reached = true
	while !_end_reached and path.size()<= 20:
		_walk()
	print(path)


func _walk():
	var mask := [1, 1, 1]
	if !moves.empty():
		var last_move: Vector2 = moves.back()
		match last_move:
			Vector2.LEFT:
				mask[2] = 0
			Vector2.RIGHT:
				mask[0] = 0
	
	var current_position: Vector2 = path.back()
	if current_position.y == bbox.y:
		mask[1] = 0
	if current_position.x == 0:
		mask[0] = 0
	if current_position.x == bbox.x:
		mask[2] = 0
	
	_action_space.set_mask(mask)
	
	var move: Vector2 = _action_space.choose_action()
	if current_position.y == 0 and !_player_reached:
		move = (player_room - current_position).normalized()
	if current_position.y == bbox.y and !_end_reached:
		move = (end_room - current_position).normalized()
	print(mask, move, current_position)
	
	var next_position: Vector2 = current_position + move
	if next_position == player_room:
		_player_reached = true
	if next_position == end_room:
		_end_reached = true
	
	moves.push_back(move)
	path.push_back(next_position)
