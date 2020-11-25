extends "res://environment/CarryItem.gd"

enum Type {WOOD, METAL, GOLD}

const BREAK_SPEED := 0.5
const BREAK_SCENE = preload("res://environment/pots/PotBreak1.tscn")

export(Type) var type

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var ray_cast: RayCast2D = $RayCast2D


func _ready():
	match type:
		Type.WOOD:
			anim_player.play("Wood")
		Type.METAL:
			anim_player.play("Metal")
		Type.GOLD:
			anim_player.play("Gold")


func _integrate_forces(state):
	ray_cast.cast_to = linear_velocity / global.TARGET_FPS
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		_break_pot()


func _break_pot():
	var lv := linear_velocity
	print(lv)
	if lv.length() > BREAK_SPEED:
		var broken = BREAK_SCENE.instance()
		get_parent().add_child(broken)
		broken.global_position = global_position
		broken.rotation = rotation
		broken.velocity = linear_velocity
		queue_free()


func _on_Pot_body_entered(body):
	_break_pot()
