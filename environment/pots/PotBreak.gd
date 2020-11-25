extends Node2D

var velocity := Vector2.ZERO setget set_velocity

onready var piece_bottom: RigidBody2D = $PotPieceBottom
onready var piece_right: RigidBody2D = $PotPieceRight
onready var piece_left: RigidBody2D = $PotPieceLeft


func set_velocity(value):
	piece_bottom.linear_velocity = value
	piece_right.linear_velocity = value
	piece_left.linear_velocity = value
