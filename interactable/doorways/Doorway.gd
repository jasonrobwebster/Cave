extends Interactable

signal door_used(target_scene, door)

export(bool) var can_use = true
export(String, FILE, "*.tscn,*.scn") var next_level = null

onready var anim_player = $AnimationPlayer


func _ready():
	if next_level == null:
		anim_player.play("Close")
	else:
		anim_player.play("Closed")
	connect("door_used", SceneManager, "_on_Doorway_door_used")


func interact():
	if not can_use:
		return
	var next_scene = next_level
	if next_scene:
		anim_player.play("Open")
	emit_signal("door_used", next_scene, self)
	
