extends TileMap
class_name RandomTileMap
# Defines a tile map that contains random tile elements. Requires nodes
# extending this to define a the cell_map inside of their ready function.

# Example:
# -------
#extends RandomTileMap
#
#
#enum Cell {autotile=2, random_grass=3}  # storing cell ids as an enum
#
#
#func _ready():
#	cell_map = {
#		Cell.autotile: {"chance": 1.0, "cell": Cell.autotile},
#		Cell.random_grass: {"chance": 0.5, "cell": Cell.autotile}
#	}


# cell_map
# Should be a dictionary containing cell ids mapped to a new dictionary with
# keys "chance": float and "cell": int. The "chance" gives the probability
# of cell becoming the cell in the "cell" key. See above example for usage.
var cell_map: Dictionary


func _ready():
	if cell_map:
		_build_tilemap_from_random_cells()


func _build_tilemap_from_random_cells():
	assert(
		cell_map, 
		"ERROR: variable 'cell_map' must be defined in _ready() function"
	)
	var _cell_vs := get_used_cells()
	for v in _cell_vs:
		var _cell := get_cellv(v)
		var _info: Dictionary = cell_map[_cell]
		
		if _info.cell == _cell:
			continue
		
		if randf() < _info.get("chance", 1.0):
			set_cellv(v, -1)
			continue
		
		set_cellv(v, _info.cell)
	
	update_bitmask_region()
	update_dirty_quadrants()
