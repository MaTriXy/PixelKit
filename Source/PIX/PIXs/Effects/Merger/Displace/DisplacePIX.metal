//
//  EffectMergerDisplacePIX.metal
//  PixelKitShaders
//
//  Created by Anton Heestand on 2017-11-14.
//  Copyright © 2017 Anton Heestand. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    float dist;
    float origin;
};

fragment float4 effectMergerDisplacePIX(VertexOut out [[stage_in]],
                                         texture2d<float>  inTexA [[ texture(0) ]],
                                         texture2d<float>  inTexB [[ texture(1) ]],
                                         const device Uniforms& in [[ buffer(0) ]],
                                         sampler s [[ sampler(0) ]]) {
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 cb = inTexB.sample(s, uv);

    float4 ca = inTexA.sample(s, float2(u + (-(cb.r - 0.5) + 0.5 - in.origin) * in.dist,
                                        v + (cb.g - in.origin) * in.dist));
    
    return ca;
}


