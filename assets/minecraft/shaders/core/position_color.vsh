#version 150

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec4 ColorModulator;

out vec4 vertexColor;
out vec2 coord;
flat out int loading;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexColor = Color;
    switch(gl_VertexID % 4) {
        case 0: coord.yx = vec2(1.0, 1.0); break;
        case 1: coord.yx = vec2(1.0, 0.0); break;
        case 2: coord.yx = vec2(0.0, 0.0); break;
        case 3: coord.yx = vec2(0.0, 1.0); break;
    }

    loading = int((gl_Position.y > 0.9999 || gl_Position.y < -0.9999) && (gl_Position.x > 0.9999 || gl_Position.x < -0.9999));
    if(Color.rgb == vec3(1.0) && distance(Color.a, 0.5) > 0.005) gl_Position.y += 1.5;
}
