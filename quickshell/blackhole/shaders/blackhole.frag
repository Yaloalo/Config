#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 resolution;
} ubuf;

const float PI = 3.14159265359;
const float TAU = 6.28318530718;
const float EVENT_HORIZON = 1.0;
const float PHOTON_SPHERE = 1.5;
const float DISK_INNER = 1.68;
const float DISK_OUTER = 6.6;
const int MAX_STEPS = 168;

float hash12(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

float hash13(vec3 p3) {
    p3 = fract(p3 * 0.1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash12(i), hash12(i + vec2(1.0, 0.0)), f.x),
               mix(hash12(i + vec2(0.0, 1.0)), hash12(i + 1.0), f.x), f.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.52;
    mat2 rotation = mat2(0.80, -0.60, 0.60, 0.80);
    for (int octave = 0; octave < 5; ++octave) {
        value += amplitude * noise(p);
        p = rotation * p * 2.06 + 17.13;
        amplitude *= 0.49;
    }
    return value;
}

vec2 sphereMap(vec3 direction) {
    direction = normalize(direction);
    return vec2(atan(direction.z, direction.x) / TAU + 0.5,
                asin(clamp(direction.y, -1.0, 1.0)) / PI + 0.5);
}

float starLayer(vec2 uv, float scale, float threshold, float t) {
    vec2 grid = uv * scale;
    vec2 cell = floor(grid);
    vec2 point = fract(grid) - 0.5;
    float seed = hash12(cell);
    vec2 offset = vec2(hash12(cell + 19.7), hash12(cell - 7.3)) - 0.5;
    float radius = mix(0.020, 0.085, pow(seed, 18.0));
    float star = smoothstep(radius, 0.0, length(point - offset * 0.60));
    float visibility = step(threshold, seed);
    float twinkle = 0.82 + 0.18 * sin(t * (0.35 + seed) + seed * 51.0);
    return star * visibility * twinkle * mix(0.45, 2.8, pow(seed, 24.0));
}

vec3 environment(vec3 direction, float t) {
    vec2 uv = sphereMap(direction);
    float stars = starLayer(uv, 420.0, 0.988, t);
    stars += 0.65 * starLayer(uv + vec2(0.173, 0.391), 760.0, 0.993, t + 7.0);
    stars += 0.28 * starLayer(uv - vec2(0.287, 0.113), 1180.0, 0.996, t + 19.0);

    // A dim stellar band gives escaped rays something continuous to lens while
    // keeping most of the desktop genuinely black.
    vec3 galacticNormal = normalize(vec3(0.17, 0.94, -0.30));
    float latitude = abs(dot(direction, galacticNormal));
    float bandNoise = fbm(uv * vec2(18.0, 7.0) + vec2(0.0, t * 0.002));
    float band = exp(-latitude * 19.0) * smoothstep(0.38, 0.90, bandNoise) * 0.11;

    float colourSeed = hash12(floor(uv * 420.0));
    vec3 starTint = mix(vec3(0.68, 0.80, 1.0), vec3(1.0, 0.93, 0.82), colourSeed);
    return starTint * stars + vec3(0.18, 0.27, 0.42) * band;
}

vec3 diskEmission(vec3 hit, vec3 rayDirection, float t, out float opacity) {
    float radius = length(hit.xz);
    float angle = atan(hit.z, hit.x);

    // Keplerian angular velocity: inner material visibly advances faster.
    float phase = angle - t * 0.48 / pow(radius, 1.5);
    float turbulence = fbm(vec2(phase * 4.2, radius * 2.8));
    float fineStructure = noise(vec2(phase * 17.0 - t * 0.045, radius * 9.0));
    float rings = 0.94 + 0.06 * sin(radius * 13.0 + turbulence * 3.0);
    float filaments = smoothstep(0.30, 0.88, turbulence * 0.84 + fineStructure * 0.22);

    // Novikov-Thorne-like radial profile, zero at the inner edge and rapidly
    // cooling outward. This is an appearance model rather than painted rings.
    float noTorque = max(0.0, 1.0 - sqrt(DISK_INNER / radius));
    float flux = noTorque / pow(radius / DISK_INNER, 2.75);
    flux *= 10.5;
    float innerHeat = 1.0 - smoothstep(DISK_INNER, DISK_OUTER, radius);

    // Special-relativistic Doppler factor for orbiting disk material.
    vec3 velocityDirection = normalize(vec3(-hit.z, 0.0, hit.x));
    float orbitalSpeed = clamp(sqrt(0.50 / max(radius - 0.78, 0.22)), 0.12, 0.62);
    float lineOfSight = dot(velocityDirection, -rayDirection);
    float doppler = sqrt(1.0 - orbitalSpeed * orbitalSpeed)
                  / max(0.32, 1.0 - orbitalSpeed * lineOfSight);
    float beaming = clamp(pow(doppler, 2.65), 0.25, 3.55);

    // Gravitational redshift damps light emitted close to the horizon.
    float redshift = sqrt(max(0.0, 1.0 - EVENT_HORIZON / radius));
    float intensity = flux * redshift * beaming;
    intensity *= mix(0.66, 1.28, filaments) * rings;

    vec3 outerColour = vec3(0.72, 0.79, 0.88);
    vec3 middleColour = vec3(0.93, 0.96, 1.00);
    vec3 innerColour = vec3(0.72, 0.88, 1.00);
    vec3 temperature = mix(outerColour, middleColour, smoothstep(0.0, 0.64, innerHeat));
    temperature = mix(temperature, innerColour, smoothstep(0.72, 1.0, innerHeat));

    float edge = smoothstep(DISK_INNER, DISK_INNER + 0.10, radius)
               * (1.0 - smoothstep(DISK_OUTER - 0.45, DISK_OUTER, radius));
    opacity = clamp(edge * (0.58 + 0.24 * filaments) * (0.55 + flux), 0.0, 0.92);
    return temperature * intensity * 1.42;
}

void main() {
    vec2 screen = qt_TexCoord0 * 2.0 - 1.0;
    float aspect = ubuf.resolution.x / max(ubuf.resolution.y, 1.0);
    screen.x *= aspect;

    // Compose left-of-centre while preserving a physically defined camera.
    screen.x += 0.27 * aspect;
    screen.y -= 0.025;

    // A wider, elevated astronomical camera keeps the complete lensed disk in
    // frame and separates its direct image from the thin far-side arcs.
    vec3 cameraPosition = vec3(0.0, 4.25, -14.5);
    vec3 forward = normalize(-cameraPosition);
    vec3 right = normalize(cross(forward, vec3(0.0, 1.0, 0.0)));
    vec3 up = normalize(cross(right, forward));
    vec3 rayDirection = normalize(forward + 0.60 * screen.x * right + 0.60 * screen.y * up);
    vec3 position = cameraPosition;

    // h² is the conserved angular-momentum term in the Schwarzschild photon
    // orbit equation. Integrating its curvature produces the primary image,
    // secondary disk image and higher-order photon-ring paths automatically.
    float angularMomentum2 = dot(cross(position, rayDirection), cross(position, rayDirection));
    vec3 radiance = vec3(0.0);
    float transmission = 1.0;
    float photonResidence = 0.0;
    bool captured = false;
    bool escaped = false;

    for (int stepIndex = 0; stepIndex < MAX_STEPS; ++stepIndex) {
        float radius = length(position);
        if (radius <= EVENT_HORIZON * 1.002) {
            captured = true;
            break;
        }
        if (radius > 15.0 && dot(position, rayDirection) > 0.0 && stepIndex > 10) {
            escaped = true;
            break;
        }

        float stepSize = clamp(radius * 0.040, 0.018, 0.24);
        vec3 previousPosition = position;

        float radius2 = radius * radius;
        float radius5 = radius2 * radius2 * radius;
        vec3 schwarzschildAcceleration = -1.5 * angularMomentum2 * position / max(radius5, 0.001);

        // Low-order Lense-Thirring term for a fast, prograde spin. It introduces
        // the slight left/right asymmetry expected from an Interstellar-like hole.
        vec3 spinAxis = vec3(0.0, 1.0, 0.0);
        vec3 frameDragging = 0.042 * cross(spinAxis, rayDirection) / max(radius2 * radius, 0.20);
        rayDirection = normalize(rayDirection + (schwarzschildAcceleration + frameDragging) * stepSize);
        position += rayDirection * stepSize;

        float photonDistance = abs(radius - PHOTON_SPHERE);
        photonResidence += exp(-photonDistance * 12.0) * stepSize;

        // A ray may cross the disk more than once after orbiting the hole. Each
        // crossing contributes a separate, correctly lensed image order.
        if (previousPosition.y * position.y <= 0.0 && abs(previousPosition.y - position.y) > 0.00001) {
            float crossing = previousPosition.y / (previousPosition.y - position.y);
            vec3 hit = mix(previousPosition, position, crossing);
            float diskRadius = length(hit.xz);
            if (diskRadius > DISK_INNER && diskRadius < DISK_OUTER && transmission > 0.015) {
                float opacity = 0.0;
                vec3 emission = diskEmission(hit, rayDirection, ubuf.time, opacity);
                radiance += transmission * emission * opacity;
                transmission *= 1.0 - opacity;
            }
        }
    }

    if (escaped && transmission > 0.001)
        radiance += transmission * environment(rayDirection, ubuf.time);

    // Long-lived near-critical geodesics form the narrow photon ring. Its light
    // is sourced by the accumulated path length, not a screen-space circle.
    float criticalGlow = smoothstep(0.16, 1.55, photonResidence)
                       * (1.0 - smoothstep(2.6, 7.0, photonResidence));
    radiance += transmission * vec3(0.52, 0.71, 1.0) * criticalGlow * 0.055;

    // Filmic exposure, gentle contrast and stable subpixel dither.
    radiance = 1.0 - exp(-radiance * 1.18);
    radiance = pow(max(radiance, vec3(0.0)), vec3(0.88));
    float dither = (hash13(vec3(gl_FragCoord.xy, floor(ubuf.time * 12.0))) - 0.5) / 255.0;
    radiance += dither;

    fragColor = vec4(clamp(radiance, 0.0, 1.0), 1.0) * ubuf.qt_Opacity;
}
