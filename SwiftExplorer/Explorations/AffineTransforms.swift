//
//  AffineTransforms.swift
//
//  Step forwards and backwards through a sequence of AffineTransforms to transform an image between
//  a source rectangle and a target rectangle.
//
//  Created by Zach Young on 3/30/21.
//  Copyright © 2021 Kenny Leung. All rights reserved.
//

import SwiftUI
import hexdreamsCocoa

struct ConcatenateTransforms: View {
    let sourceRect = CGRect(x: 120, y: 20, width: 500, height: 500)
    let targetRect = CGRect(x: 20, y: 400, width: 100, height: 100)

    /// From [https://math.stackexchange.com/a/3249175/272082]:
    ///
    /// > Rotation and scaling matrices are usually defined around the origin. To perform these transformations about an arbitrary point, you would translate the point about which the transformation is to occur to the origin, perform the transformation as normal, and then undo the translation. This process is then repeated for each transformation required.
    ///
    var tOffset:CGAffineTransform {
        let originOffsetX = sourceRect.minX
        let originOffsetY = sourceRect.minY
        return CGAffineTransform(translationX: originOffsetX, y: originOffsetY).inverted()
    }

    var tTranslate:CGAffineTransform {
        let xOffset = targetRect.minX - sourceRect.minX
        let yOffset = targetRect.minY - sourceRect.minY
        return CGAffineTransform(translationX: xOffset, y: yOffset)
    }

    var tScale:CGAffineTransform {
        let scale = targetRect.size.width / sourceRect.size.width
        return CGAffineTransform(scaleX: scale, y: scale)
    }

    // For demo purposes only: I want to be able to move backwards to a state before
    // the transform at index 0, the "starting/rest point of the sequence of transforms":
    //
    //          [ tOffset, ..., tOffset.inverted() ]
    //   start,   0      , 1.., end
    //
    let sequenceStart = -1
    var tSequence:[(s:String, t:CGAffineTransform)] {
        [
            ("set to origin", tOffset),
            ("scaled", tScale),
            ("translated", tTranslate),
            ("unset from origin", tOffset.inverted())
        ]
    }
    var sequenceEnd:Int { tSequence.count-1 }

    @State var transformStatus = "At Source"
    @State var transformState = -1
    @State var transform = CGAffineTransform.identity

    var body: some View {
        let tRect = sourceRect.applying(transform)
        VStack {
            GeometryReader { _ in
                // Source
                Rectangle()
                    .fill(Color.green)
                    .frame(width: sourceRect.size.width, height: sourceRect.size.height)
                    .position(x: sourceRect.midX, y: sourceRect.midY)

                // Target
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: targetRect.size.width, height: targetRect.size.height)
                    .position(x: targetRect.midX, y: targetRect.midY)

                // Transforming image/rect
                Image("Grid")
                    .resizable()
                    .frame(width: tRect.size.width-3, height: tRect.size.height-3)  // don't bleed to edge
                    .position(x: tRect.midX, y: tRect.midY)
            } // GeometryReader
            .background(Color.gray)

            HStack {
                Spacer()

                Button(action: { transformState -= 1 }) {
                    Image(systemName: "arrow.left.circle")
                        .font(.system(size: 56.0))
                }
                .disabled(transformState == sequenceStart)

                Spacer()
                Text("\(transformStatus)")
                    .font(.system(size: 40))
                    .frame(minWidth:600)
                Spacer()

                Button(action: { transformState += 1 }) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 56.0))
                }
                .disabled(transformState == sequenceEnd)

                Spacer()
            } // HStack
        } // VStack
        .onChange(of: transformState) { [transformState] newState in
            let oldState = transformState
            if (newState > oldState) {
                let sequence = tSequence[newState]  // apply new state
                transformStatus = sequence.s
                transform = transform.concatenating(sequence.t)
            } else {
                let sequence = tSequence[oldState]  // undo old state
                transformStatus = "un-" + sequence.s
                transform = transform.concatenating(sequence.t.inverted())
            }

            print("\(transformStatus)")
            transform.print()

            if (newState == sequenceStart) {
                transformStatus += " / At Source"
            } else if (newState == sequenceEnd) {
                transformStatus += " / At Target"
            }
        }
    }
}

/// https://stackoverflow.com/a/39215372/246801
extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            let pad = String(repeatElement(character, count: toLength - stringLength))
            return pad + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

extension CGAffineTransform {
    func print() -> Void {
        let t = self
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.maximumSignificantDigits = 4

        let values = [t.a, t.b, t.c, t.d, t.tx, t.ty]
            .map { fmt.string(for: $0)! }
        let max = values.max { (a, b) in a.count < b.count }!.count
        let paddedValues = values
            .map { $0.leftPadding(toLength: max, withPad: " ")}

        var a,b,c,d,tx,ty: String
        a = paddedValues[0]
        b = paddedValues[1]
        c = paddedValues[2]
        d = paddedValues[3]
        tx = paddedValues[4]
        ty = paddedValues[5]

        let s = "┌ \(a) \(b)  0 ┐\n" + "│ \(c) \(d)  0 │\n" + "└ \(tx) \(ty)  1 ┘\n"
        Swift.print(s)
    }
}
