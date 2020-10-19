extends KinematicBody2D


enum States {
	IDLE,
	MOVE,
	JUMP,
	CLIMB,
}

const MAX_FALL_SPEED := 400
const MAX_MOVE_SPEED := 64
const MAX_DECCELERATION := 50
const JUMP_FORCE := 170
const FLOOR_ACC := 25
const AIR_ACC := 1
const FLOOR_FRICTION := 25
const AIR_FRICTION := 0
const COYOTE_TIME := 0.05
const HOVER_SPEED := 30

var velocity := Vector2.ZERO
var state

var _snap := true
var friction := 0
var acceleration := 0

onready var sprite = $Sprite
onready var anim_player = $AnimationPlayer
onready var collision_down = $CollisionDown
onready var collision_up = $CollisionUp
onready var coyote_timer = $CoyoteTimer


func _ready():
	_state_change(States.MOVE)


func _physics_process(delta):
	var fdelta: float = delta * global.TARGET_FPS
	_update_fsm(fdelta)
	_apply_gravity(fdelta)
	_caluculate_velocity(fdelta)
	_move()


func _update_fsm(fdelta):
	match state:
		States.IDLE, States.MOVE:
			_state_move(fdelta)
		States.JUMP:
			_state_jump(fdelta)


func _caluculate_velocity(fdelta):
	var input_right := Input.get_action_strength("ui_right")
	var input_left := Input.get_action_strength("ui_left")
	var input_x := input_right - input_left
	if input_x != 0:
		velocity.x = move_toward(
			velocity.x, 
			input_x*MAX_MOVE_SPEED, 
			acceleration * fdelta
		)
		if state != States.JUMP:
			_state_change(States.MOVE)
		sprite.flip_h = input_x > 0
		sprite.offset.x = - int(input_x > 0)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			friction * fdelta
		)
		if state != States.JUMP:
			_state_change(States.IDLE)
	_bring_speed_to_max(fdelta)


func _state_move(fdelta):
	if not is_on_floor():
		_state_change(States.JUMP)
		coyote_timer.start(COYOTE_TIME)
	if Input.is_action_just_pressed("jump"):
		velocity += global.up_direction * JUMP_FORCE
		_state_change(States.JUMP)


func _state_jump(fdelta):
	var jump_speed := velocity.dot(global.up_direction)
	if jump_speed > HOVER_SPEED and anim_player.current_animation != "JumpDown":
		anim_player.play("JumpDown")
	elif -HOVER_SPEED <= jump_speed and jump_speed <= HOVER_SPEED and anim_player.current_animation != "JumpMid":
		anim_player.play("JumpMid")
	elif jump_speed < -HOVER_SPEED and anim_player.current_animation != "JumpUp":
		anim_player.play("JumpUp")
	if Input.is_action_just_pressed("jump") and coyote_timer.time_left > 0:
		velocity.y = 0
		velocity += global.up_direction * JUMP_FORCE
		coyote_timer.stop()
	if is_on_floor():
		_state_change(States.MOVE)


func _state_change(desired_state):
	if state == desired_state:
		return
	match desired_state:
		States.IDLE:
			anim_player.play("Idle")
			continue
		States.MOVE:
			anim_player.play("Walk")
			anim_player.playback_speed = 1
			friction = FLOOR_FRICTION
			acceleration = FLOOR_ACC
			_snap = true
		States.JUMP:
			anim_player.play("JumpUp")
			friction = AIR_FRICTION
			acceleration = AIR_ACC
			_snap = false
	state = desired_state


func _apply_gravity(fdelta):
	velocity -= global.gravity * global.up_direction * fdelta


func _bring_speed_to_max(fdelta):
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
	velocity = move_and_slide_with_snap(
		velocity, 
		-global.up_direction * float(_snap), 
		global.up_direction
	)
