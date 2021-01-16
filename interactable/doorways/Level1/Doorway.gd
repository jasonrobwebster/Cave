extends Interactable

signal door_used()

export(bool) var can_use = true
export(String, FILE, "*.tscn,*.scn") var next_level = null
export(String, FILE, "*.tscn,*.scn") var next_room = null


func interact(_player):
	if not can_use:
		return
	emit_signal("door_used")
	if global.next_level() == 0:
		get_tree().change_scene_to(load(next_room))
	else:
		get_tree().change_scene_to(load(next_level))
