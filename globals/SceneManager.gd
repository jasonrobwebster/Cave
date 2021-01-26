extends Node2D

const TWEEN_RADIUS_SIZE := 300
const TWEEN_DURATION := 0.5

export (NodePath) var camera_path
export (NodePath) var player_path
export (bool) var drawing_circle = false setget set_draw_circle
export (Vector2) var circle_origin = Vector2.ZERO setget set_circle_origin
export (float) var circle_radius = 0 setget set_circle_radius

onready var post_processing := $CanvasLayer/PostProcessing
onready var tween := $Tween
onready var timer := $Timer


func _physics_process(delta):
	var t = Transform2D(0, Vector2())
	var camera = get_node_or_null(camera_path)
	if camera != null:
		var canvas_transform = camera.get_canvas_transform()
		var top_left = -canvas_transform.origin / canvas_transform.get_scale()
		t = Transform2D(0, top_left)
	post_processing.material.set_shader_param("global_transform", t)


func tween_open_radius():
	self.drawing_circle = true
	tween.stop_all()
	tween.interpolate_property(self, "circle_radius", 0, TWEEN_RADIUS_SIZE, TWEEN_DURATION * 2, Tween.TRANS_LINEAR)
	tween.start()


func tween_close_radius():
	self.drawing_circle = true
	tween.stop_all()
	tween.interpolate_property(self, "circle_radius", TWEEN_RADIUS_SIZE, 0, TWEEN_DURATION, Tween.TRANS_LINEAR)
	tween.start()


func set_circle_origin(origin: Vector2):
	circle_origin = origin
	post_processing.material.set_shader_param("circle_origin", origin)


func set_circle_radius(radius: float):
	circle_radius = radius
	post_processing.material.set_shader_param("circle_radius", radius)


func set_draw_circle(drawing: bool):
	drawing_circle = drawing
	post_processing.material.set_shader_param("draw_circle", drawing)


func change_scene(target_scene: PackedScene):
	tween_close_radius()
	yield(tween, "tween_all_completed")
	get_tree().change_scene_to(target_scene)


func _on_Doorway_door_used(target_scene: String, door: Node2D):
	# this is a messy implementation, but it works for now
	var player = get_node_or_null(player_path)
	if player:
		player.global_position = door.global_position
		player.handle_change_scene()
	self.circle_origin = door.global_position
	tween_close_radius()
	yield(tween, "tween_all_completed")
	get_tree().change_scene(target_scene)


func _on_level_finished():
	var player = get_node_or_null(player_path)
	if player:
		self.circle_origin = player.global_position
	tween_open_radius()
	yield(tween, "tween_all_completed")
	self.drawing_circle = false
	
