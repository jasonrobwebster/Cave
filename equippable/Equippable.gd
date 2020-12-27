extends Node2D
class_name Equippable

enum EquipType {TOOL, WEAPON, THROWABLE}

export(PackedScene) var debris_scene
export(EquipType) var equip_type
export(float, 0, 1) var spawn_chance = 1

onready var state_machine: StateMachine = $StateMachine


func equip(new_parent: Node2D):
	if state_machine.current_state.name == 'Equipped':
		return
	state_machine.change_state("Equipped", new_parent)


func unequip():
	if state_machine.current_state.name == 'Unequipped':
		return
	state_machine.change_state("Unequipped")


func _on_Unequipped_thrown_collision():
	if debris_scene:
		var debris = debris_scene.instance()
		get_parent().add_child(debris)
		debris.global_position = global_position
	queue_free()
