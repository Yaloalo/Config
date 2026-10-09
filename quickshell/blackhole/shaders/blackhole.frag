#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
} ubuf;

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
               mix(hash21(i + vec2(0.0, 1.0)), hash21(i + 1.0), f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    mat2 turn = mat2(0.80, -0.60, 0.60, 0.80);
    for (int i = 0; i < 4; ++i) {
        value += amplitude * noise(p);
        p = turn * p * 2.03 + 11.7;
        amplitude *= 0.5;
    }
    return value;
}

float stars(vec2 p, float t) {
    vec2 cell = floor(p * 145.0);
    vec2 local = fract(p * 145.0) - 0.5;
    float seed = hash21(cell);
    float point = smoothstep(0.050, 0.0, length(local));
    float rare = step(0.982, seed);
    float twinkle = 0.74 + 0.26 * sin(t * 0.8 + seed * 37.0);
    return point * rare * twinkle * (0.55 + 1.8 * pow(seed, 16.0));
}

void main() {
    vec2 uv = qt_TexCoord0;
    float aspect = ubuf.resolution.x / max(ubuf.resolution.y, 1.0);
    vec2 p = (uv - vec2(0.39, 0.52)) * vec2(aspect, 1.0);
    float r = length(p);
    float angle = atan(p.y, p.x);
    float t = ubuf.time;

    // Thin-lens Schwarzschild approximation. The source field is pulled around
    // the Einstein radius, producing a moving, doubled star field near the hole.
    const float einstein2 = 0.038;
    vec2 lensed = p * (1.0 - einstein2 / max(r * r, 0.004));
    float frameDrag = 0.018 * exp(-r * 4.5) * sin(t * 0.13);
    float cs = cos(frameDrag);
    float sn = sin(frameDrag);
    lensed = mat2(cs, -sn, sn, cs) * lensed;

    float starLight = stars(lensed + vec2(t * 0.0007, 0.0), t);
    starLight += 0.45 * stars(lensed * 1.73 - vec2(0.31, t * 0.0004), t + 9.0);
    vec3 colour = vec3(starLight) * vec3(0.76, 0.87, 1.0);

    // Projected accretion plane and its secondary lensed image. Turbulence
    // rotates at an approximate Keplerian r^-3/2 rate.
    float orbital = t * (0.11 + 0.055 / pow(max(r, 0.19), 1.5));
    float plasma = fbm(vec2(angle * 4.8 + orbital, r * 34.0));
    plasma = smoothstep(0.24, 0.91, plasma);

    float radialMask = smoothstep(0.18, 0.235, r) * (1.0 - smoothstep(0.69, 1.02, r));
    float planeWidth = 0.010 + 0.016 * smoothstep(0.20, 0.85, r);
    float primaryDisk = smoothstep(planeWidth, 0.0, abs(p.y + p.x * 0.018));

    float ellipse = sqrt(p.x * p.x + (p.y / 0.85) * (p.y / 0.85));
    float backArc = smoothstep(0.020, 0.002, abs(ellipse - 0.285));
    backArc *= 1.0 - smoothstep(-0.04, 0.18, p.y);
    float lowerArc = 0.30 * smoothstep(0.015, 0.003, abs(ellipse - 0.255));
    lowerArc *= smoothstep(-0.03, 0.15, p.y);

    // Relativistic Doppler beaming: the approaching (left) side is brighter.
    float doppler = mix(0.46, 1.72, smoothstep(0.50, -0.50, p.x));
    float disk = (primaryDisk + backArc + lowerArc) * radialMask * (0.48 + 0.75 * plasma) * doppler;
    float temperature = smoothstep(0.72, 0.20, r);
    vec3 diskColour = mix(vec3(0.34, 0.55, 0.76), vec3(0.97, 0.99, 1.0), temperature);
    colour += diskColour * disk * 1.9;

    // The photon sphere is narrow and white-blue; the event horizon remains
    // truly black and occludes every source behind it.
    float photonRing = exp(-pow((r - 0.188) / 0.0034, 2.0));
    photonRing *= 0.64 + 0.36 * smoothstep(0.40, -0.35, p.x);
    colour += vec3(0.75, 0.90, 1.0) * photonRing * 1.18;

    float horizon = 1.0 - smoothstep(0.154, 0.159, r);
    colour *= 1.0 - horizon;

    // Subtle infinity-blue halo, strongest at the critical curve.
    float halo = exp(-pow((r - 0.205) / 0.030, 2.0)) * 0.055;
    colour += vec3(0.10, 0.38, 0.92) * halo * (1.0 - horizon);

    colour = 1.0 - exp(-colour * 1.18);
    colour *= 1.0 - 0.25 * smoothstep(0.45, 1.35, length((uv - 0.5) * 1.45));
    fragColor = vec4(colour, 1.0) * ubuf.qt_Opacity;
}
