extends Position2D

export(NodePath) var player_path setget set_player
export(Rect2) var camera_limits setget set_camera_limits

const LOOK_DISTANCE = 60

var _player: KinematicBody2D

onready var camera := $Camera
onready var tween := $Tween
onready var timer := $Timer


func _ready():
	_player = get_node(player_path)
	follow_player()
	_set_camera_limits(camera_limits)


func _input(event):
	if event.is_action_pressed("ui_down"):
		timer.stop()
		timer.start(1)
	elif event.is_action_released("ui_down"):
		timer.stop()
		_reset_cam()
	elif event.is_action_pressed("ui_up"):
		timer.stop()
		timer.start(1)
	elif event.is_action_released("ui_up"):
		timer.stop()
		_reset_cam()


func setup_camera():
	follow_player()


func set_player(player: NodePath):
	player_path = player
	_player = get_node(player_path)


func set_camera_limits(value: Rect2):
	camera_limits = value
	if camera:
		_set_camera_limits(value)


func _set_camera_limits(value: Rect2):
	if value:
		camera.limit_left = value.position.x
		camera.limit_top = value.position.y
		camera.limit_right = value.position.x + value.size.x
		camera.limit_bottom = value.position.y + value.size.y


func follow_player():
	_player.get_node("RemoteTransform2D").remote_path = self.get_path()


func _look(end: Vector2):
	tween.interpolate_property(
		camera, 
		"position", 
		camera.position, 
		end,
		0.5,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween.start()


func _reset_cam():
	tween.stop_all()
	tween.interpolate_property(
		camera, 
		"position", 
		camera.position, 
		Vector2(camera.position.x, 0),
		0.5,
		Tween.TRANS_QUART,
		Tween.EASE_OUT
	)
	tween.start()


func _on_Timer_timeout():
	if Input.is_action_pressed("ui_down"):
		_look(Vector2(camera.position.x, LOOK_DISTANCE))
	elif Input.is_action_pressed("ui_up"):
		_look(Vector2(camera.position.x, -LOOK_DISTANCE))
