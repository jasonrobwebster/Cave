extends Node2D

const TWEEN_RADIUS_SIZE := 370
const TWEEN_DURATION := 0.75
const MAIN_MENU_SCENE := "res://ui/MainMenu.tscn"

export (NodePath) var camera_path
export (NodePath) var player_path
export (bool) var drawing_circle = false setget set_draw_circle
export (Vector2) var circle_origin = Vector2.ZERO setget set_circle_origin
export (float) var circle_radius = 0 setget set_circle_radius

onready var post_processing := $CanvasLayer/PostProcessing
onready var tween: Tween = $Tween
onready var timer: Timer = $Timer
onready var anim_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta):
	var t = Transform2D(0, Vector2())
	var camera = get_node_or_null(camera_path)
	if camera != null:
		var canvas_transform = camera.get_canvas_transform()
		var top_left = -canvas_transform.origin / canvas_transform.get_scale()
		t = Transform2D(0, top_left)
	post_processing.material.set_shader_param("global_transform", t)


func transition_to_main_menu():
	var player = get_node_or_null(player_path)
	if player:
		self.circle_origin = player.global_position
	else:
		self.circle_origin = _get_viewport_center()
	tween_close_radius()
	yield(tween, "tween_all_completed")
	get_tree().change_scene(MAIN_MENU_SCENE)
	yield(get_tree().create_timer(0.5), "timeout")
	player = get_node_or_null(player_path)
	if player:
		self.circle_origin = player.global_position
	else:
		self.circle_origin = _get_viewport_center()
	tween_open_radius()
	yield(tween, "tween_all_completed")
	self.drawing_circle = false


func tween_open_radius():
	self.drawing_circle = true
	tween.stop_all()
	tween.interpolate_property(self, "circle_radius", 0, TWEEN_RADIUS_SIZE, TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func tween_close_radius():
	self.drawing_circle = true
	tween.stop_all()
	self.circle_radius = TWEEN_RADIUS_SIZE
	tween.interpolate_property(self, "circle_radius", TWEEN_RADIUS_SIZE, 0, TWEEN_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
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


func _get_viewport_center() -> Vector2:
	var view_transform: Transform2D = get_viewport_transform()
	var view_scale: Vector2 = view_transform.get_scale()
	return -view_transform.origin / view_scale + get_viewport_rect().size / scale / 2


func _on_Doorway_door_used(target_scene: String, door: Node2D):
	# this is a messy implementation, but it works for now
	var player = get_node_or_null(player_path)
	if player:
		player.global_position = door.global_position
		player.handle_change_scene()
		yield(player.anim_player, "animation_finished")
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


func _on_player_change_state(new_state: Node, previous_state: Node):
	if new_state.name != "Dead":
		return
	# play a death animation
	tween.stop_all()
	var player = get_node_or_null(player_path)
	if player:
		self.circle_origin = player.global_position
	self.drawing_circle = true
	anim_player.play("Death")
	yield(anim_player, "animation_finished")
	# go to the main menu
	get_tree().change_scene(MAIN_MENU_SCENE)
	yield(get_tree().create_timer(0.5), "timeout")
	player = get_node_or_null(player_path)
	if player:
		self.circle_origin = player.global_position
	else:
		self.circle_origin = _get_viewport_center()
	tween_open_radius()
	yield(tween, "tween_all_completed")
	self.drawing_circle = false
