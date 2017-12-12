//
//  BoundingBox.swift
//  SerranoYOLO
//
//  Created by ZHONGHAO LIU on 12/2/17.
//  Copyright © 2017 Serrano. All rights reserved.
//

import Foundation
import UIKit

public class BoundingBox: Equatable, Hashable {
    
    public var x: Float
    public var y: Float
    public var w: Float
    public var h: Float
    public var label: String
    public var score: Float
    public let shapeLayer: CAShapeLayer
    public let textLayer: CATextLayer
    
    
    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
    
    public init(x: Float, y: Float, w: Float, h: Float, label: String, score: Float) {
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.label = label
        self.score = score
        
        self.shapeLayer = CAShapeLayer()
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.lineWidth = 4
        self.shapeLayer.isHidden = true
        
        self.textLayer = CATextLayer()
        self.textLayer.foregroundColor = UIColor.black.cgColor
        self.textLayer.isHidden = true
        self.textLayer.contentsScale = UIScreen.main.scale
        self.textLayer.fontSize = 14
        self.textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
        self.textLayer.alignmentMode = kCAAlignmentCenter
    }
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        parent.addSublayer(textLayer)
    }
    
    func show(frame: CGRect, color: UIColor) {
        CATransaction.setDisableActions(true)
        
        let path = UIBezierPath(rect: frame)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
        
        textLayer.string = label
        textLayer.backgroundColor = color.cgColor
        textLayer.isHidden = false
        let attributes = [String:Any]()

        let textRect = self.label.boundingRect(with: CGSize(width: 400, height: 100),
                                          options: .truncatesLastVisibleLine,
                                          attributes: attributes, context: nil)
        let textSize = CGSize(width: textRect.width + 12, height: textRect.height)
        let textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
        textLayer.frame = CGRect(origin: textOrigin, size: textSize)
    }
    
    public static func ==(lhs: BoundingBox, rhs: BoundingBox) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.w == rhs.w && lhs.h == rhs.h && lhs.label == rhs.label
    }
    
    public static func !=(lhs: BoundingBox, rhs: BoundingBox) -> Bool {
        return !(lhs == rhs)
    }
}
