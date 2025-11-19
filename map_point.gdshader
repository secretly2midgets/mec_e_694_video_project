shader_type canvas_item;

uniform vec4 colour;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (distance(UV, vec2(0.5,0.5)) < 0.5)
		COLOR = colour;
	else
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
