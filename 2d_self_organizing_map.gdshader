shader_type canvas_item;

const vec2 screen_size = vec2(1080,1920);
const int data_size = 1024;
const int map_size  = 64;

uniform float neighborhood_radius;
uniform vec2 data[data_size];
uniform vec2 map[map_size];

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment()
{
	COLOR = vec4(1.0,1.0,1.0,1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
