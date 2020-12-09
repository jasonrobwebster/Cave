extends EnemyBaseState

onready var pivot: Position2D = owner.get_node("Pivot")
onready var sprite: Sprite = owner.get_node("Pivot/Sprite")
onready var anim_player: AnimationPlayer = owner.get_node("AnimationPlayer")
onready var floor_ray: RayCast2D = owner.get_node("Pivot/FloorRay")
onready var wall_ray: RayCast2D = owner.get_node("Pivot/WallRay")


func _ready():
	_rng.randomize()


func enter(_previous_state: String = '', _args = null):
	# handle entering state
	pass


func exit():
	# state cleanup
	pass


func update(_delta):
	# called during _physics_process
	_move()
	_update_pivot(pivot)
	pass


func handle_input(_event):
	# called during _unhandled_input
	pass
