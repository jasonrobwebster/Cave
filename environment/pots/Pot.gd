extends "res://environment/CarryItem.gd"

enum Type {WOOD, METAL, GOLD}

const BREAK_SPEED := 1
const BREAK_SCENES = [
	preload("res://environment/pots/PotBreak1.tscn"),
	preload("res://environment/pots/PotBreak2.tscn"),
]
const VALUES: Dictionary = {
	Type.WOOD: 0,
	Type.METAL: 10,
	Type.GOLD: 100,
}

export(Type) var type setget set_type

var value := 0 setget ,get_value

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var ray_cast: RayCast2D = $RayCast2D


func _ready():
	anim_player.play(_type_animation())


func _integrate_forces(state):
	ray_cast.cast_to = linear_velocity / global.TARGET_FPS
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		_break_pot()


func set_type(t):
	type = t
	value = VALUES[type]
	if anim_player:
		anim_player.play(_type_animation())


func get_value():
	return value


func _type_animation() -> String:
	var out := ""
	match type:
		Type.WOOD:
			out = "Wood"
		Type.METAL:
			out = "Metal"
		Type.GOLD:
			out = "Gold"
	return out


func _break_pot():
	var lv := linear_velocity
	if lv.length() > BREAK_SPEED:
		var broken = BREAK_SCENES[randi() % len(BREAK_SCENES)].instance()
		get_parent().add_child(broken)
		broken.global_position = global_position
		broken.rotation = rotation
		broken.velocity = linear_velocity
		broken.type = type
		queue_free()


func _on_Pot_body_entered(body):
	if contact_monitor:
		_break_pot()
