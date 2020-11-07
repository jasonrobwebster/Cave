extends RandomTileMap

enum Cell {autotile=0, random_auto=1, grass=2, random_grass=3}


func _ready():
	cell_map = {
		Cell.autotile: {"chance": 1.0, "cell": Cell.autotile},
		Cell.random_auto: {"chance": 0.5, "cell": Cell.autotile},
		Cell.grass: {"chance": 1.0, "cell": Cell.grass},
		Cell.random_grass: {"chance": 0.5, "cell": Cell.grass}
	}
	._ready()
