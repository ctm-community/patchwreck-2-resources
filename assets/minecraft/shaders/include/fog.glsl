#version 150

const float  startMult_l = 0.02;
const float   fadeMult_l = 8.0;
const float brightMult_l = 0.3;
const float brightThre_l = 0.05;
const float brightDimm_l = 0.0;
const vec3   colorMult_l = vec3(165.0, 195.0, 205.0) / 255.0;

const float  startMult_w = 1.0;
const float   fadeMult_w = 1.0;
const float brightMult_w = 0.5;
const float brightThre_w = 0.6;
const float brightDimm_w = 0.01;
const vec3   colorMult_w = vec3(255.0, 255.0, 255.0) / 255.0;

const vec3     nightGlow = vec3(6.0, 1.0, 9.0) / 255.0;

const vec3  skyColorMult = vec3(225.0, 215.0, 203.0) / 255.0;
const float      skyFade = 0.5;

const float whiteMult = 0.4;
const float whiteBright = 600.00; //these control conditional biomes

const float purpMult = 1.08;


float rgbToLinear(float channel) {
    return channel <= 0.04045 ? channel / 12.92 : pow(((channel + 0.055) / 1.055), 2.4);
}

float luminance(vec3 rgb) {
    return 0.2126 * rgbToLinear(rgb.r) + 0.7152 * rgbToLinear(rgb.g) + 0.0722 * rgbToLinear(rgb.b);
}

float perceivedBrightness(float luminance) {
    return luminance <= 216.0 / 24389.0 ? luminance * 24389.0 / 27.0 : pow(luminance, 1.0 / 3.0) * 116.0 - 16.0;
}

float perceivedBrightness(vec3 rgb) {
    return perceivedBrightness(luminance(rgb));
}

vec4 linear_fog(vec4 inColor, float vertexDistance, float fogStart, float fogEnd, vec4 fogColor) {
    
    
    bool blind = fogEnd < 6.0;

    float  startMult = fogStart < 0.1 ?  startMult_w :  startMult_l;
    float   fadeMult = fogStart < 0.1 ?   fadeMult_w :   fadeMult_l;
    float brightMult = fogStart < 0.1 ? brightMult_w : brightMult_l;
    float brightThre = fogStart < 0.1 ? brightThre_w : brightThre_l;
    float brightDimm = fogStart < 0.1 ? brightDimm_w : brightDimm_l;
    vec3   colorMult = fogStart < 0.1 ?  colorMult_w :  colorMult_l;

    float white_dist = distance(fogColor, vec4(0.0,0.0,0.0,0.9)); //this is the conditional biome!
    if(white_dist < 0.2) {
        white_dist = 1.0 - white_dist / 0.1;
        fadeMult = mix(fadeMult, fadeMult * whiteMult, white_dist);
        brightDimm = mix(brightDimm, brightDimm * whiteBright, white_dist);
    }

   

    float fogRange = fogEnd - fogStart;
    fogStart *= startMult;
    fogEnd = fogStart + fogRange * fadeMult;
    fogColor.rgb *= colorMult;

    if(blind) {
        fogEnd *= 0.35;
    }

    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;

    if(!blind) {
        float relBrightness = clamp((perceivedBrightness(inColor.rgb) - perceivedBrightness(fogColor.rgb)) / 60.0, 0.0, 1.0);
        float fogLoss = clamp(relBrightness - brightThre, 0.0, 1.0) * brightMult;
        fogValue = clamp(fogValue - fogLoss, 0.0, 1.0);
        if(vertexDistance - fogEnd > 20.0) fogValue += mix(0.0, fogLoss, clamp((vertexDistance - fogEnd - 20.0) * brightDimm, 0.0, 1.0));
    }


    fogColor.rgb += clamp(nightGlow * (60.0 - perceivedBrightness(fogColor.rgb)) / 60.0, vec3(0.0), vec3(1.0));

    if(blind) fogColor = vec4(0.0, 0.0, 0.0, 1.0);

    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue * fogColor.a), inColor.a);
}

float linear_fog_fade(float vertexDistance, float fogStart, float fogEnd) {
    if (vertexDistance <= fogStart) {
        return 1.0;
    } else if (vertexDistance >= fogEnd) {
        return 0.0;
    }

    return smoothstep(fogEnd, fogStart, vertexDistance);
}

float fog_distance(mat4 modelViewMat, vec3 pos, int shape) {
    if (shape == 0) {
        return length((modelViewMat * vec4(pos, 1.0)).xyz);
    } else {
        float distXZ = length((modelViewMat * vec4(pos.x, 0.0, pos.z, 1.0)).xyz);
        float distY = length((modelViewMat * vec4(0.0, pos.y, 0.0, 1.0)).xyz);
        return max(distXZ, distY);
    }
}
