extends KinematicBody2D


onready var center: Position2D = $Center
onready var head: Position2D = $Head


func _on_Hurtbox_area_entered(area: Hitbox):
	if area.get("damage"):
		PlayerStats.health -= area.damage

