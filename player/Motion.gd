extends State

const TARGET_FPS := 60
const MAX_FALL_SPEED := 400
const MAX_MOVE_SPEED := 64
const MAX_DECCELERATION := 50
const AIR_ACC := 1
const JUMP_FORCE := 170
const COYOTE_TIME := 0.1

var _snap: bool
var velocity: Vector2

onready var sprite: Sprite = owner.get_node("Sprite")
onready var anim_player: AnimationPlayer = owner.get_node("AnimationPlayer")
onready var collision: CollisionShape2D = owner.get_node("Collision")
onready var coyote_timer: Timer = owner.get_node("CoyoteTimer")


func update(delta):
	_apply_gravity(delta)
	_bring_speed_to_max(delta)
	_move()


func _apply_gravity(delta):
	var fdelta: float = delta * global.TARGET_FPS
	velocity -= global.gravity * global.up_direction * fdelta


func _bring_speed_to_max(delta):
	var fdelta: float = delta * global.TARGET_FPS
	if abs(velocity.x) > MAX_MOVE_SPEED:
		velocity.x = move_toward(
			velocity.x,
			sign(velocity.x) * MAX_MOVE_SPEED,
			MAX_DECCELERATION * fdelta
		)
	if abs(velocity.y) > MAX_FALL_SPEED:
		velocity.y = move_toward(
			velocity.y,
			sign(velocity.y) * MAX_FALL_SPEED,
			MAX_DECCELERATION * fdelta
		)

func _move():
	velocity = owner.move_and_slide_with_snap(
		velocity, 
		-global.up_direction * float(_snap), 
		global.up_direction
	)


func _get_input_x() -> float:
	var input_right := Input.get_action_strength("ui_right")
	var input_left := Input.get_action_strength("ui_left")
	var input_x := input_right - input_left
	return input_x
