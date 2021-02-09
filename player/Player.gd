extends KinematicBody2D

signal camera_shake_requested()

onready var state_machine := $StateMachine
onready var anim_player := $AnimationPlayer
onready var sprite := $Pivot/Sprite
onready var center := $Center
onready var head := $Head
onready var carry_pivot: Position2D = $Pivot/CarryPivot


func _ready():
	SceneManager.player_path = get_path()
	PlayerStats.player_path = get_path()


func handle_change_scene():
	state_machine.active = false
	anim_player.stop()
	anim_player.play("WalkIn")


func _on_Hurtbox_area_entered(area: Hitbox):
	if area.get("damage"):
		emit_signal("camera_shake_requested")


func _on_Hurtbox_invincibility_started():
	if state_machine.active:
		state_machine.change_state("Hurt", state_machine.current_state.velocity)
		sprite.material.set_shader_param("blinking", true)


func _on_Hurtbox_invincibility_ended():
	sprite.material.set_shader_param("blinking", false)


func _on_Hurtbox_Hurt(area: Hitbox):
	if area.get("damage") and state_machine.active:
		PlayerStats.health -= area.damage
