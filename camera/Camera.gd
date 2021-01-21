extends Camera2D

export(float, 0, 10, 0.1) var shake_amplitude = 6.0
export(float, 0, 10, 0.1) var shake_duration = 0.7 setget set_duration
export(float, EASE) var shake_easing = 1.0
export(bool) var shake = false setget set_shake

var _rng = RandomNumberGenerator.new()

onready var timer := $Timer


func _ready():
	_rng.randomize()
	set_process(false)
	self.shake_duration = shake_duration


func _process(delta):
	var damping := ease(timer.time_left / timer.wait_time, shake_easing)
	offset = Vector2(
		_rng.randf_range(-shake_amplitude, shake_amplitude) * damping,
		_rng.randf_range(-shake_amplitude, shake_amplitude) * damping
	)


func set_duration(value):
	shake_duration = value
	if timer:
		timer.wait_time = value


func set_shake(value):
	shake = value
	set_process(value)
	offset = Vector2.ZERO
	if shake:
		timer.start()


func connect_to_shakers():
	for shaker in get_tree().get_nodes_in_group("camera_shaker"):
		shaker.connect("camera_shake_requested", self, "_on_camera_shake_requested")


func _on_camera_shake_requested():
	self.shake = true
