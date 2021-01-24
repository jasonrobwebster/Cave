extends Interactable

signal door_used(target_scene)

export(bool) var can_use = true
export(String, FILE, "*.tscn,*.scn") var next_level = null
export(String, FILE, "*.tscn,*.scn") var next_room = null

onready var anim_player = $AnimationPlayer


func _ready():
	if next_level == null and next_room == null:
		anim_player.play("Close")
	else:
		anim_player.play("Closed")


func interact(player):
	if not can_use:
		return
	anim_player.play("Open")
	var next_scene = null
	if global.next_level() == 0:
		next_scene = load(next_room)
	else:
		next_scene = load(next_level)
	emit_signal("door_used", next_scene)
	
