//
//  ChromaKeyPIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-23.
//  Open Source - MIT License
//

public class ChromaKeyPIX: PIXSingleEffect, PIXAuto {
    
    override open var shader: String { return "effectSingleChromaKeyPIX" }
    
    // MARK: - Public Properties
    
    public var keyColor: LiveColor = .green
    public var range: LiveFloat = LiveFloat(0.1, min: 0.0, max: 0.5)
    public var softness: LiveFloat = LiveFloat(0.1, min: 0.0, max: 0.5)
    public var edgeDesaturation: LiveFloat = 0.5
    public var premultiply: LiveBool = true
    
    // MARK: - Property Helpers
    
    override public var liveValues: [LiveValue] {
        return [keyColor, range, softness, edgeDesaturation, premultiply]
    }
    
    // MARK: - Life Cycle
    
    public required init() {
        super.init()
        name = "chromaKey"
    }
    
}

public extension PIXOut {
    
    func _chromaKey(_ color: LiveColor) -> ChromaKeyPIX {
        let chromaKeyPix = ChromaKeyPIX()
        chromaKeyPix.name = ":chromaKey:"
        chromaKeyPix.inPix = self as? PIX & PIXOut
        chromaKeyPix.keyColor = color
        return chromaKeyPix
    }
    
}
