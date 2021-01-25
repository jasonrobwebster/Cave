extends TextureRect

export (NodePath) var camera_path


func _physics_process(delta):
	var t = Transform2D(0, Vector2())
	var camera = get_node_or_null(camera_path)
	if camera != null:
		var canvas_transform = camera.get_canvas_transform()
		var top_left = -canvas_transform.origin / canvas_transform.get_scale()
		t = Transform2D(0, top_left)
	material.set_shader_param("global_transform", t)
