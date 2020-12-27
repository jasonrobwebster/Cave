extends State

const MAX_MOVE_SPEED := 400
const MAX_DECELERATION := 50

var velocity: Vector2 = Vector2.ZERO

onready var sprite: Sprite = owner.get_node("Sprite")


func enter(_previous_state: String = '', _args = null):
	# handle entering state
	pass


func exit():
	# state cleanup
	pass


func update(delta):
	_apply_gravity(delta)
	_bring_speed_to_max(delta)
	_move()


func handle_input(_event):
	# called during _unhandled_input
	pass


func _bring_speed_to_max(delta):
	var fdelta: float = delta * global.TARGET_FPS
	if velocity.length() > MAX_MOVE_SPEED:
		velocity = velocity.move_toward(
			velocity.normalized() * MAX_MOVE_SPEED,
			MAX_DECELERATION * fdelta
		)

func _apply_gravity(delta):
	var fdelta: float = delta * global.TARGET_FPS
	velocity -= global.gravity * global.up_direction * fdelta


func _move():
	velocity = owner.move_and_slide_with_snap(
		velocity, 
		-global.up_direction, 
		global.up_direction
	)
