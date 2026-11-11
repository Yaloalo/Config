#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float travel;
    float warp;
    float fallingMode;
    float strength;
    vec4 tintColor;
    vec2 resolution;
    vec2 grid;
} ubuf;

float hash(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

float layer(vec2 uv, float index) {
    float phase = fract(1.0 - ubuf.travel + index * 0.317);
    float scale = mix(1.8, 0.56, phase);
    vec2 count = max(vec2(1.0), ubuf.grid * (index == 0.0 ? 0.55 : index == 1.0 ? 1.0 : 1.7));
    vec2 field = ubuf.fallingMode > 0.5
        ? vec2(uv.x, fract(uv.y - phase * (0.15 + index * 0.10))) * count
        : (vec2(0.5) + (uv - vec2(0.5)) * scale) * count;
    vec2 cell = floor(field);
    vec2 local = fract(field);
    vec2 star = vec2(hash(cell + index * 19.7), hash(cell + index * 31.3));
    float life = hash(cell + index * 43.1);
    float starRadius = mix(0.7, 1.45, hash(cell + index * 54.2));
    // Distances are in logical pixels, so changing the monitor scale cannot
    // turn a dot into a wide blurred rectangle.
    vec2 delta = (local - star) * (ubuf.resolution / count) / scale;
    float radial = length(delta);
    float dotStar = 1.0 - smoothstep(starRadius * 0.4, starRadius * 1.6, radial);
    float streak = 0.0;
    if (ubuf.warp > 0.001 && ubuf.fallingMode < 0.5) {
        vec2 direction = normalize(uv - vec2(0.5) + vec2(0.0001));
        float along = dot(delta, direction);
        float across = abs(delta.x * direction.y - delta.y * direction.x);
        float lengthPx = ubuf.warp * mix(9.0, 34.0, phase);
        streak = (1.0 - smoothstep(0.0, starRadius, across))
            * smoothstep(-lengthPx, -lengthPx + 3.0, along)
            * (1.0 - smoothstep(-2.0, 1.0, along)) * 0.6;
    }
    float fade = ubuf.fallingMode > 0.5 ? 1.0
        : smoothstep(0.0, 0.16, phase) * (1.0 - smoothstep(0.86, 1.0, phase));
    return max(dotStar, streak) * fade * (0.3 + 0.7 * life);
}

void main() {
    vec2 uv = qt_TexCoord0;
    float stars = layer(uv, 0.0) + layer(uv, 1.0) + layer(uv, 2.0);
    float alpha = clamp(stars * ubuf.strength * ubuf.qt_Opacity, 0.0, 1.0);
    fragColor = vec4(ubuf.tintColor.rgb * alpha, alpha);
}
