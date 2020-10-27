extends KinematicBody2D


func _on_Hurtbox_area_entered(area: Hitbox):
	if area.get("damage"):
		PlayerStats.health -= area.damage



