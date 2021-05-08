//
//  ContentGeneratorRectanglePIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-17.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float sx;
    float sy;
    float x;
    float y;
//    float rot;
    float crad;
    float ar;
    float ag;
    float ab;
    float aa;
    float br;
    float bg;
    float bb;
    float ba;
    float premultiply;
    float resx;
    float resy;
    float aspect;
    float tile;
    float tileX;
    float tileY;
    float tileResX;
    float tileResY;
    float tileFraction;
};

fragment float4 contentGeneratorRectanglePIX(VertexOut out [[stage_in]],
                                              const device Uniforms& in [[ buffer(0) ]],
                                              sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    if (in.tile > 0.0) {
        u = (in.tileX / in.tileResX) + u * in.tileFraction;
        v = (in.tileY / in.tileResY) + v * in.tileFraction;
    }
    
    float4 ac = float4(in.ar, in.ag, in.ab, in.aa);
    float4 bc = float4(in.br, in.bg, in.bb, in.ba);
    
    float4 c = bc;
    
    float x = (u - 0.5) * in.aspect;
    float y = v - 0.5;
    
//    float _x = in.x;
//    float _y = in.y;
//
//    float _rot = atan2(_y, _x);
//    float _rad = sqrt(pow(_x, 2) + pow(-y, 2));
//    _rot += in.rot;
//
//    float __x = cos(_rot) * _rad;
//    float __y = sin(_rot) * _rad;
    
    float left = in.x - in.sx / 2;
    float right = in.x + in.sx / 2;
    float bottom = -in.y - in.sy / 2;
    float top = -in.y + in.sy / 2;
    
    float width = right - left;
    float height = top - bottom;
    
    float crad = min(min(in.crad, width / 2), height / 2);
   
    float in_x = x > left && x < right;
    float in_y = y > bottom && y < top;
    
    if (crad == 0.0) {
        if (in_x && in_y) {
            c = ac;
        }
    } else {
        float in_x_inset = x > left + crad && x < right - crad;
        float in_y_inset = y > bottom + crad && y < top - crad;
        if ((in_x_inset && in_y) || (in_x && in_y_inset)) {
            c = ac;
        }
        float2 c1 = float2(left + crad, bottom + crad);
        float2 c2 = float2(left + crad, top - crad);
        float2 c3 = float2(right - crad, bottom + crad);
        float2 c4 = float2(right - crad, top - crad);
        float c1r = sqrt(pow(x - c1.x, 2) + pow(y - c1.y, 2));
        float c2r = sqrt(pow(x - c2.x, 2) + pow(y - c2.y, 2));
        float c3r = sqrt(pow(x - c3.x, 2) + pow(y - c3.y, 2));
        float c4r = sqrt(pow(x - c4.x, 2) + pow(y - c4.y, 2));
        if (c1r < crad || c2r < crad || c3r < crad || c4r < crad) {
            c = ac;
        }
    }
    
    if (in.premultiply) {
        c = float4(c.r * c.a, c.g * c.a, c.b * c.a, c.a);
    }
    
    return c;
}
