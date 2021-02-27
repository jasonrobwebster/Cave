extends "res://player/PlayerState.gd"


func enter(_previous_state: String = '', _args = null):
	anim_player.play("Hurt")


func exit():
	# state cleanup
	pass


func update(_delta):
	# called during _physics_process
	pass


func handle_input(_event):
	# called during _unhandled_input
	pass
