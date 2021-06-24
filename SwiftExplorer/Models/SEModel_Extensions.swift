//
//  SEModel_Extensions.swift
//  SwiftExplorer
//
//  Created by Zach Young on 6/24/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//
import Foundation
import CoreGraphics

extension AreaOfInterest {
    var rect:CGRect? {
        get {
            if let rX = self.rect_X,
               let rY = self.rect_Y,
               let rW = self.rect_W,
               let rH = self.rect_H {
                return CGRect(
                    x:      CGFloat(rX.floatValue),
                    y:      CGFloat(rY.floatValue),
                    width:  CGFloat(rW.floatValue),
                    height: CGFloat(rH.floatValue)
                )
            }

            if self.rect_X != nil || self.rect_Y != nil || self.rect_W != nil || self.rect_H != nil {
                let allValues = [self.rect_X, self.rect_Y, self.rect_W, self.rect_H]
                fatalError("Some but not all rect_ values were nil: [xywh] \(allValues),")
            }

            return nil
        }

        set {
            guard let nnNewValue = newValue else {
                self.rect_X = nil
                self.rect_Y = nil
                self.rect_W = nil
                self.rect_H = nil
                return
            }
            self.rect_X = NSNumber(value: Float(nnNewValue.minX))
            self.rect_Y = NSNumber(value: Float(nnNewValue.minY))
            self.rect_W = NSNumber(value: Float(nnNewValue.width))
            self.rect_H = NSNumber(value: Float(nnNewValue.height))
        }
    }

}
