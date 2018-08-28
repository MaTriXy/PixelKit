//
//  LookupPIX.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-18.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import CoreGraphics

public class LookupPIX: PIXMergerEffect, PIXofaKind {
    
    let kind: PIX.Kind = .lookup
    
    override var shader: String { return "effectMergerLookupPIX" }
    
    public enum Axis: String, Codable {
        case x
        case y
    }
    
    var holdEdgeFraction: CGFloat {
        guard let res = resolution else { return 0 }
        let axisRes = axis == .x ? res.width : res.height
        return 1 / axisRes
    }
    
    public var axis: Axis = .x { didSet { setNeedsRender() } }
    public var holdEdge: Bool = true { didSet { setNeedsRender() } }
    enum CodingKeys: String, CodingKey {
        case axis; case holdEdge
    }
    override var uniforms: [CGFloat] {
        return [axis == .x ? 0 : 1, holdEdge ? 1 : 0, holdEdgeFraction]
    }
    
    public override init() {
        super.init()
    }
    
    // MARK: JSON
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        axis = try container.decode(Axis.self, forKey: .axis)
        holdEdge = try container.decode(Bool.self, forKey: .holdEdge)
        setNeedsRender()
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(axis, forKey: .axis)
        try container.encode(holdEdge, forKey: .holdEdge)
    }
    
}