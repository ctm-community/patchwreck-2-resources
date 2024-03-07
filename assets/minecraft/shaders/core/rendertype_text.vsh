#version 150

#define HEIGHT 30.0

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec2 ScreenSize;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out float depthLevel;
out float GT;
flat out vec3 pos;

int guiScale(mat4 ProjMat, vec2 ScreenSize) {
    return int(round(ScreenSize.x * ProjMat[0][0] / 2));
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    pos = gl_Position.xyz;

    int marker = int(Color.r * 255);
	if (Color.r == Color.g) {
		marker == 0;
		return;
	}
	//hiding text shadow
    if (marker == 62) {
        gl_Position = ProjMat * ModelViewMat * vec4(Position + vec3(0.0,0.0,0.0), 0.0);
        return;
    }
    if (marker == 251) {
		vec3 Pos = Position;
		switch(gl_VertexID % 4) {
			case 0: //-,+
			Pos.y = round(ScreenSize.y / (guiScale(ProjMat, ScreenSize))) - (HEIGHT + 27.0);
			
			break;
			case 1: //+,+
			Pos.y = round(ScreenSize.y / (guiScale(ProjMat, ScreenSize))) - HEIGHT;
			
			break;
			case 2: //+,-
			Pos.y = round(ScreenSize.y / (guiScale(ProjMat, ScreenSize))) - HEIGHT;
			
			break;
			case 3: //-,-
			Pos.y = round(ScreenSize.y / (guiScale(ProjMat, ScreenSize))) - (HEIGHT + 27.0);
			
			break;
		}
        gl_Position = ProjMat * ModelViewMat * vec4(Pos, 1.0);
        return;
    }
    depthLevel = -1*gl_Position.w;
}
