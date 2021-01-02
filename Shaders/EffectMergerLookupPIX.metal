//
//  EffectMergerLookupPIX.metal
//  PixelKit Shaders
//
//  Created by Anton Heestand on 2017-11-26.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float axis;
    float holdEdge;
    float holdEdgeFraction;
};

fragment float4 effectMergerLookupPIX(VertexOut out [[stage_in]],
                                      texture2d<float>  inTexA [[ texture(0) ]],
                                      texture2d<float>  inTexB [[ texture(1) ]],
                                      const device Uniforms& in [[ buffer(0) ]],
                                      sampler s [[ sampler(0) ]]) {
    
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 ca = inTexA.sample(s, uv);
    float a = ca.a;
    float cac = (ca.r + ca.g + ca.b) / 3;
    if (in.holdEdge) {
        if (cac < in.holdEdgeFraction) {
            cac = in.holdEdgeFraction;
        } else if (cac > 1 - in.holdEdgeFraction) {
            cac = 1 - in.holdEdgeFraction;
        }
    }
    
    float2 cbuv = 0.5;
    if (in.axis < 0.5) {
        cbuv[0] = cac;
    } else {
        cbuv[1] = cac;
    }
    float4 cb = inTexB.sample(s, cbuv);
    
    return float4(cb.r, cb.g, cb.b, a);
}
