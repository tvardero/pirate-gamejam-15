shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture; 
vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	//COLOR.a = texture(TEXTURE, UV).a;
	float dis = distance(UV,vec2(0.5,0.5)) * 100.0;
	dis = clamp(dis * 2.0, 0.0,100.0);
	dis = clamp(dis - 25.0, 0.0,100.0);
	COLOR.a = min(texture(TEXTURE, UV).a,(1.0 / 100.0) * (100.0 - dis));
}
