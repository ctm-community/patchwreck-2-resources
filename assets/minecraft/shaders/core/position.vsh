#version 150

in vec3 Position;

uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

void main() {
    vec4 pos = ProjMat * vec4(Position, 1.0);
	pos.y = -pos.z;
	gl_Position = pos;
}
