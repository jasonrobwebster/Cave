extends Equippable

export(int) var value = 0

func _on_Unequipped_thrown_collision():
	PlayerStats.score += value
	._on_Unequipped_thrown_collision()
