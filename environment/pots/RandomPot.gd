extends Position2D

export(float, 0, 1) var WOODEN_CHANCE = 0.9
export(float, 0, 1) var METAL_CHANCE = 0.09

export(float, 0, 1) var spawn_chance = 0.9

var _rng = RandomNumberGenerator.new()

onready var pot := $Pot

func _ready():
	_rng.randomize()
	var spawn = _rng.randf()
	if spawn > spawn_chance:
		queue_free()
		return
	var chance = _rng.randf()
	if chance <= WOODEN_CHANCE:
		pot.type = pot.Type.WOOD
		return
	chance -= WOODEN_CHANCE
	if chance <= METAL_CHANCE:
		pot.type = pot.Type.METAL
		return
	pot.type = pot.Type.GOLD
