//
//  MetalMultiEffectPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-09-07.
//  Open Source - MIT License
//

/// Metal Shader (Multi Effect)
///
/// vars: pi, u, v, uv, pixCount
///
/// Example:
/// ~~~~swift
/// let metalMultiEffectPix = MetalMultiEffectPIX(code:
///     """
///     float4 inPixA = inTexs.sample(s, uv, 0);
///     float4 inPixB = inTexs.sample(s, uv, 1);
///     float4 inPixC = inTexs.sample(s, uv, 2);
///     pix = inPixA + inPixB + inPixC;
///     """
/// )
/// metalMultiEffectPix.inPixs = [ImagePIX("img_a"), ImagePIX("img_b"), ImagePIX("img_c")]
/// ~~~~
public class MetalMultiEffectPIX: PIXMultiEffect, PIXMetal {
    
    override open var shader: String { return "effectMultiMetalPIX" }
    
    // MARK: - Private Properties
    
    let metalFileName = "EffectMultiMetalPIX.metal"
    
    public override var shaderNeedsAspect: Bool { return true }
    
    var metalUniforms: [MetalUniform]
    
    var metalEmbedCode: String
    var metalCode: String? {
        do {
            return try pixelKit.embedMetalCode(uniforms: metalUniforms, code: metalEmbedCode, fileName: metalFileName)
        } catch {
            pixelKit.log(pix: self, .error, .metal, "Metal code could not be generated.", e: error)
            return nil
        }
    }
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return metalUniforms.map({ uniform -> LiveFloat in return uniform.value })
    }
    
//    enum CodingKeys: String, CodingKey {
//        case metalUniforms
//    }
    
//    open override var uniforms: [CGFloat] {
//        return metalUniforms.map({ metalUniform -> CGFloat in
//            return metalUniform.value
//        })
//    }
    
    public init(uniforms: [MetalUniform] = [], code: String) {
        metalUniforms = uniforms
        metalEmbedCode = code
        super.init()
        name = "metalMultiEffect"
    }
    
    required override init() {
        metalUniforms = []
        metalEmbedCode = ""
        super.init()
    }
    
//    // MARK: - JSON
//    
//    required convenience init(from decoder: Decoder) throws {
//        self.init(code: "") // CHECK
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        metalUniforms = try container.decode([MetalUniform].self, forKey: .metalUniforms)
//        setNeedsRender()
//    }
//    
//    override public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(metalUniforms, forKey: .metalUniforms)
//    }
    
}
