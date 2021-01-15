//
//  DisplacePIX.swift
//  PixelKit
//
//  Created by Anton Heestand on 2018-09-06.
//  Open Source - MIT License
//

import CoreGraphics
import RenderKit

public class DisplacePIX: PIXMergerEffect {
    
    override open var shaderName: String { return "effectMergerDisplacePIX" }
    
    // MARK: - Public Properties
    
    @Live public var distance: CGFloat = 1.0
    @Live public var origin: CGFloat = 0.5
    
    // MARK: - Property Helpers
    
    public override var liveList: [LiveWrap] {
        [_distance, _origin] + super.liveList
    }
    
    override public var values: [Floatable] {
        return [distance, origin]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init(name: "Displace", typeName: "pix-effect-merger-displace")
        extend = .hold
    }
    
}

public extension NODEOut {
    
    func displace(with pix: PIX & NODEOut, distance: CGFloat) -> DisplacePIX {
        let displacePix = DisplacePIX()
        displacePix.name = ":displace:"
        displacePix.inputA = self as? PIX & NODEOut
        displacePix.inputB = pix
        displacePix.distance = distance
        return displacePix
    }
    
    func noiseDisplace(distance: CGFloat, zPosition: CGFloat = 0.0, octaves: Int = 10) -> DisplacePIX {
        let pix = self as! PIX & NODEOut
        let noisePix = NoisePIX(at: pix.renderResolution)
        noisePix.name = "noiseDisplace:noise"
        noisePix.colored = true
        noisePix.zPosition = zPosition
        noisePix.octaves = octaves
        return pix.displace(with: noisePix, distance: distance)
    }
    
}
