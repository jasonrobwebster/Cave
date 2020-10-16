extends RandomTileMap


enum Cell {autotile=2, random_grass=3}


func _ready():
	cell_map = {
		Cell.autotile: {"chance": 1.0, "cell": Cell.autotile},
		Cell.random_grass: {"chance": 0.5, "cell": Cell.autotile}
	}
