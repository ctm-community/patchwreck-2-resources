#version 150

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;

in vec2 texCoord0;

out vec4 fragColor;

void main() {
    if(distance(texture(Sampler0, vec2(0.0, 11.0 / 512.0)).a, 20.0 / 255.0) < 0.0001) discard; //Mojank is no more

    vec4 color = texture(Sampler0, texCoord0);
    if(color.a == 0.0) discard;
    fragColor = color * ColorModulator;
}
