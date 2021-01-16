extends Node2D

enum Type {WOOD, METAL, GOLD}
enum Variant {VARIANT1, VARIANT2}

const TWEEN_DELAY := 0.75
const TWEEN_DURATION := 0.15


export(Type) var type setget set_type
export(Variant) var variant

var velocity := Vector2.ZERO setget set_velocity

onready var piece_bottom: RigidBody2D = $PotPieceBottom
onready var piece_right: RigidBody2D = $PotPieceRight
onready var piece_left: RigidBody2D = $PotPieceLeft
onready var tween: Tween = $Tween


func _ready():
	for piece in [piece_bottom, piece_left, piece_right]:
		tween.interpolate_property(
			piece.get_node("Sprite"), 
			"modulate:a", 
			1, 
			0, 
			TWEEN_DURATION, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN,
			TWEEN_DELAY
		)
	tween.start()


func set_velocity(value):
	piece_bottom.linear_velocity = value
	piece_right.linear_velocity = value
	piece_left.linear_velocity = value


func set_type(value):
	piece_bottom.get_node("Sprite").frame_coords.x = 2 * value + variant
	piece_right.get_node("Sprite").frame_coords.x = 2 * value + variant
	piece_left.get_node("Sprite").frame_coords.x = 2 * value + variant
	type = value


func _on_Tween_tween_all_completed():
	queue_free()
