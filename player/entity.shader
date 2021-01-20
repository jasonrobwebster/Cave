shader_type canvas_item;
render_mode unshaded;

uniform bool blinking = false;

const float PI = 3.14159265358979323846;
const float blink_freq = 4.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 white = vec4(1.0, 1.0, 1.0, color.a);
	float angle = 2.0 * PI * blink_freq * float(blinking) * TIME;
	vec4 output = color * round((cos(angle) + 1.0)/2.0) + white * round((cos(angle+PI) + 1.0)/2.0);
	COLOR = output;
}