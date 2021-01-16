extends Node2D


func _ready():
	var state = get_world_2d().get_direct_space_state()
	var result = state.intersect_point(Vector2(263, 153), 32, [], 1)
	if result:
		print(result)
		print("TRUE")
