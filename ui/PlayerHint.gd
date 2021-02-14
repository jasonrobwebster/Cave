extends Node2D

enum {
	LMB,
	RMB
}

enum {
	NONE,
	MOUSE,
	SPACE
}

const TWEEN_DURATION = 0.2

var hinting := NONE
var nb_bodies := 0
var mouse_hint := RMB

onready var mouse_sprite := $Mouse/Sprite
onready var mouse_anim_player := $Mouse/AnimationPlayer
onready var tween := $Tween
onready var space_sprite := $Space/Sprite
onready var space_anim_player:= $Space/AnimationPlayer


func _ready():
	mouse_sprite.modulate = Color(1, 1, 1, 0)
	space_sprite.modulate = Color(1, 1, 1, 0)


func _input(event):
	if event.is_action_pressed("pickup") and nb_bodies > 0:
		if mouse_hint == RMB:
			mouse_hint = LMB
			mouse_anim_player.play("LMB Highlight")
	if event.is_action_pressed("throw") and mouse_hint == LMB:
		mouse_hint = RMB
		hinting = NONE
		hide_sprite(mouse_sprite)


func show_sprite(sprite: Sprite):
	tween.interpolate_property(
		sprite, 
		"modulate", 
		Color(1, 1, 1, 0), 
		Color(1, 1, 1, 1),
		TWEEN_DURATION,
		tween.TRANS_QUAD,
		tween.EASE_IN
	)
	tween.start()


func hide_sprite(sprite: Sprite):
	tween.interpolate_property(
		sprite, 
		"modulate", 
		Color(1, 1, 1, 1), 
		Color(1, 1, 1, 0),
		TWEEN_DURATION,
		tween.TRANS_QUAD,
		tween.EASE_IN
	)
	tween.start()


func _on_Area2D_entered(body: Node2D):
	if body.is_in_group("equipable") and hinting == NONE:
		if mouse_hint == RMB:
			show_sprite(mouse_sprite)
			mouse_anim_player.play("RMB Highlight")
		hinting = MOUSE
		nb_bodies += 1
	if body.is_in_group("interactable") and hinting == NONE:
		show_sprite(space_sprite)
		space_anim_player.play("SpaceHighlight")
		hinting = SPACE


func _on_Area2D_exited(body: Node2D):
	if body.is_in_group("equipable"):
		nb_bodies -= 1
	if nb_bodies <= 0:
		nb_bodies = 0
		match hinting:
			SPACE:
				hinting = NONE
				hide_sprite(space_sprite)
			MOUSE:
				if mouse_hint == RMB: 
					hide_sprite(mouse_sprite)
					hinting=NONE
