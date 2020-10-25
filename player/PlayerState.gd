extends State

onready var pivot: Position2D = owner.get_node("Pivot")
onready var anim_player: AnimationPlayer = owner.get_node("AnimationPlayer")
onready var collision: CollisionShape2D = owner.get_node("Collision")
onready var coyote_timer: Timer = owner.get_node("CoyoteTimer")


func _get_input_x() -> float:
	var input_right := Input.get_action_strength("ui_right")
	var input_left := Input.get_action_strength("ui_left")
	var input_x := input_right - input_left
	return input_x
