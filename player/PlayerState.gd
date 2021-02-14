extends State

signal start_run()
signal end_run()

var velocity: Vector2 = Vector2.ZERO

onready var sprite: Sprite = owner.get_node("Pivot/Sprite")
onready var pivot: Position2D = owner.get_node("Pivot")
onready var anim_player: AnimationPlayer = owner.get_node("AnimationPlayer")
onready var collision: CollisionShape2D = owner.get_node("Collision")
onready var coyote_timer: Timer = owner.get_node("CoyoteTimer")
onready var interact_zone : Area2D = owner.get_node("InteractZone")
onready var equippable_zone : Area2D = owner.get_node("Pivot/EquippableZone")
onready var carry_pivot: Position2D = owner.get_node("Pivot/CarryPivot")


func _get_input_x() -> float:
	var input_right := Input.get_action_strength("ui_right")
	var input_left := Input.get_action_strength("ui_left")
	var input_x := input_right - input_left
	return input_x


func _get_input_run(run_multiplier: float) -> float:
	var input_run = Input.get_action_strength("run") * run_multiplier + 1.0
	return input_run
