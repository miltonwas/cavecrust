// Mine shaft in perspective for a 400 x 280 view (Godot 4, canvas_item).
// Put it on a ColorRect that covers the view (size 400 x 280, or scaled with integer factors).
// Import every PNG below with: Compress = Lossless, Mipmaps off, Filter = Nearest.
shader_type canvas_item;
render_mode unshaded;

uniform sampler2D map_uv : filter_nearest;      // RG = strip column (16 bit), B = light (low 4 bits) | flags << 4
uniform sampler2D map_depth : filter_nearest;   // RG = (depth in strip rows + 512) * 16
uniform sampler2D palette : filter_nearest;     // 16 brightness steps x material rows
uniform sampler2D strip_level1 : filter_nearest;
uniform sampler2D strip_t12 : filter_nearest;
uniform sampler2D strip_level2 : filter_nearest;
uniform sampler2D strip_t23 : filter_nearest;
uniform sampler2D strip_level3 : filter_nearest;

uniform float depth_rows = 0.0;   // how far the platform has descended, in strip rows (1 row = 0.5 world units)
uniform int tiles_level1 = 3;     // how many strip lengths of each level before its transition
uniform int tiles_level2 = 3;

const ivec2 VIEW = ivec2(400, 280);

int dec16(vec2 v) {
	ivec2 b = ivec2(round(v * 255.0));
	return b.x * 256 + b.y;
}

int floordiv(int a, int b) {
	return a >= 0 ? a / b : -((-a + b - 1) / b);
}

// x = stone id, y = palette row, z = tone
ivec3 stone_at(ivec2 p) {
	p = clamp(p, ivec2(0), VIEW - ivec2(1));
	int col = dec16(texelFetch(map_uv, p, 0).rg);
	float drow = float(dec16(texelFetch(map_depth, p, 0).rg)) / 16.0 - 512.0;
	int nv = textureSize(strip_level1, 0).y;
	int vrow = int(floor(drow + depth_rows));
	int tile = floordiv(vrow, nv);
	ivec2 t = ivec2(col, vrow - tile * nv);
	vec3 s;
	if (tile < tiles_level1) s = texelFetch(strip_level1, t, 0).rgb;
	else if (tile == tiles_level1) s = texelFetch(strip_t12, t, 0).rgb;
	else if (tile < tiles_level1 + 1 + tiles_level2) s = texelFetch(strip_level2, t, 0).rgb;
	else if (tile == tiles_level1 + 1 + tiles_level2) s = texelFetch(strip_t23, t, 0).rgb;
	else s = texelFetch(strip_level3, t, 0).rgb;
	ivec3 b = ivec3(round(s * 255.0));
	return ivec3(b.r + (b.g & 15) * 256, b.b, b.g >> 4);
}

void fragment() {
	ivec2 p = ivec2(floor(UV * vec2(VIEW)));
	ivec3 c = stone_at(p);
	int right = p.x < VIEW.x - 1 ? stone_at(p + ivec2(1, 0)).x : c.x;
	int down = p.y < VIEW.y - 1 ? stone_at(p + ivec2(0, 1)).x : c.x;
	int up = p.y > 0 ? stone_at(p + ivec2(0, -1)).x : c.x;
	int m = int(round(texelFetch(map_uv, p, 0).b * 255.0));
	int light = m & 15;
	int flags = m >> 4;
	bool rock = c.y <= 2;
	bool deco = c.y >= 3 && c.y <= 6;
	bool emissive = c.y >= 7;
	int b;
	if (rock) b = light + c.z - 8;
	else if (deco) b = max(light, 7) + c.z - 8;
	else b = c.z;
	if (up != c.x && !emissive) b += 1;            // lit top edge of every stone
	if ((flags & 1) != 0) b += 3;                  // lip of the cut rock
	if ((flags & 2) != 0) b -= 1;                  // shadow next to the cut
	if (right != c.x || down != c.x) b -= emissive ? 3 : 7;   // 1 px outline
	b = clamp(b, 0, 15);
	COLOR = vec4(texelFetch(palette, ivec2(b, c.y), 0).rgb, 1.0);
}
