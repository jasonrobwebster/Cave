extends RandomTileMap

enum Cell {autotile=0, random_grass=1}


func _ready():
	cell_map = {
		Cell.autotile: {"chance": 1.0, "cell": Cell.autotile},
		Cell.random_grass: {"chance": 0.5, "cell": Cell.autotile}
	}
	._ready()
