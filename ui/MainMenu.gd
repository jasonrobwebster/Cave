extends Node2D


func _on_Doorway_door_used(target_scene, door):
	# reset all the player stats for the start of the game
	PlayerStats.health = PlayerStats.max_health
	PlayerStats.score = 0
	PlayerStats.equip_texture = null
	# equipped items are stored as children in the player stats node
	# remove them
	for child in PlayerStats.get_children():
		child.queue_free()
