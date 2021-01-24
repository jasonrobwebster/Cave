shader_type canvas_item;

uniform bool draw_circle = false;
uniform vec2 circle_origin = vec2(0, 0);
uniform float circle_radius = 1000;
uniform mat4 global_transform;

varying vec2 world_position;


void vertex() {
	world_position = (global_transform * vec4(VERTEX, 0.0, 1.0)).xy;
}


void fragment() {
	vec2 frag_coord = world_position;
	vec3 screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	
	// set color outside circle radius to black
	float dist = distance(circle_origin, frag_coord);
	if (draw_circle) {
		screen = screen * float(dist < circle_radius);
	}
	
	COLOR.rgb = screen;
}
