#version 150

#moj_import <gpu_noise_lib.glsl>
#moj_import <fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform float GameTime;
uniform vec2 ScreenSize;
uniform mat4 ProjMat;
uniform mat4 ModelViewMat;

out vec4 fragColor;

vec3 distort_space(vec3 v, float amt) {
    return v * (1.0 + (SimplexPerlin3D(v) + 1.0) * amt);
}

void main() {
    vec4 cast_pos = normalize(inverse(ProjMat) * vec4((gl_FragCoord.xy / ScreenSize - 0.5) * 2.0, 1.0, 1.0));
    vec3 v = normalize(cast_pos.xyz * mat3(ModelViewMat));

    vec4 fog = FogColor * vec4(colorMult_l, 1.0);
    vec4 sky = ColorModulator * vec4(skyColorMult, 1.0);
    float m = pow(clamp(v.y + 0.2, 0.0, 1.0), skyFade);

    fragColor = mix(fog, sky, m);

    float stars = SimplexPolkaDot3D(distort_space(v * 30.0, 0.1), 0.24, 0.8);
//  float stars = SimplexPolkaDot3D(distort_space(v * 20.0, 0.1), 0.18, 0.8);

    fragColor += stars * mix(0.8, 0.0, pow(length(fragColor.rgb) / length(vec3(1.0)), 0.1));
}
