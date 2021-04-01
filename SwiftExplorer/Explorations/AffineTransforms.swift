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

struct World {
    let sourceRect = CGRect(x: 320, y: 20, width: 500, height: 500)
    let targetRect = CGRect(x: 50, y: 300, width: 100, height: 100)

    // From [https://math.stackexchange.com/a/3249175/272082]:
    //
    // > Rotation and scaling matrices are usually defined around the origin. To perform these transformations about an arbitrary point, you would translate the point about which the transformation is to occur to the origin, perform the transformation as normal, and then undo the translation. This process is then repeated for each transformation required.
    //

    var tOffset:CGAffineTransform {
        let originOffsetX = sourceRect.minX
        let originOffsetY = sourceRect.minY
        return CGAffineTransform(translationX: originOffsetX, y: originOffsetY).inverted()
    }

    // The actual "geometry transforms"
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
            ("unset from origin", tOffset.inverted()),
        ]
    }
    var sequenceEnd:Int { tSequence.count-1 }
}

struct ViewPort: View {
    let tAnimation:CGAffineTransform
    let tViewPort:CGAffineTransform
    let world:World

    @GestureState var dragState = CGSize.zero
    @State var viewState = CGSize.zero
    var tView:CGAffineTransform {
        let tX = viewState.width + dragState.width
        let tY = viewState.height + dragState.height
        return tViewPort.concatenating(CGAffineTransform(translationX: tX, y: tY))
    }

    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { (value, state, transaction) in
                state = value.translation
            }
            .onEnded { value in
                viewState.width += value.translation.width
                viewState.height += value.translation.height
            }

        let sourceRect = world.sourceRect.applying(tView)
        let targetRect = world.targetRect.applying(tView)
        let tRect = world.sourceRect.applying(tAnimation.concatenating(tView))

        GeometryReader { geoReader in
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

            // Origin x-hairs
            Path { path in
                let origin = CGPoint(x: 0, y: 0).applying(tView)
                let extentX = CGPoint(x: 200, y: 0).applying(tView)
                let extentY = CGPoint(x: 0, y: 200).applying(tView)
                path.move(to: origin)
                path.addLine(to: extentX)
                path.move(to: origin)
                path.addLine(to: extentY)
            }
            .stroke(Color.black, lineWidth: 1)

        } // GeometryReader
        .gesture(drag)
        .clipped()
    }
}


struct ConcatenateTransforms: View {
    @State var animationStatus = "At Source"
    @State var animationState = -1
    @State var tAnimation = CGAffineTransform.identity

    var world = World()

    var body: some View {
        let tView1 = CGAffineTransform.identity
        let tView2 = CGAffineTransform(scaleX: 0.5, y: 0.25)
        let tView3 = CGAffineTransform(scaleX: 0.2, y: 0.2)
            .concatenating(CGAffineTransform(translationX: 200, y: 200))

        // wrong order, we can see the translation of 200 scaled down to 40
        let tView4 = CGAffineTransform(translationX: 200, y: 200)
            .concatenating(CGAffineTransform(scaleX: 0.2, y: 0.2))

        VStack {
            ViewPort(tAnimation: tAnimation, tViewPort: tView1, world: world)
                .background(Color.gray)

            HStack {
                ViewPort(tAnimation: tAnimation, tViewPort: tView2, world: world)
                    .background(Color.gray)

                VStack {
                    ViewPort(tAnimation: tAnimation, tViewPort: tView3, world: world)
                        .background(Color.gray)
                    ViewPort(tAnimation: tAnimation, tViewPort: tView4, world: world)
                        .background(Color.gray)
                }
            }

            HStack {
                Spacer()

                Button(action: { animationState -= 1 }) {
                    Image(systemName: "arrow.left.circle")
                        .font(.system(size: 56.0))
                }
                .disabled(animationState == world.sequenceStart)

                Spacer()
                Text("\(animationStatus)")
                    .font(.system(size: 40))
                    .frame(minWidth:600)
                Spacer()

                Button(action: { animationState += 1 }) {
                    Image(systemName: "arrow.right.circle")
                        .font(.system(size: 56.0))
                }
                .disabled(animationState == world.sequenceEnd)

                Spacer()
            } // HStack

        } // VStack
        .onChange(of: animationState) { [animationState] newState in
            let oldState = animationState
            if (newState > oldState) {
                let sequence = world.tSequence[newState]  // apply new state
                animationStatus = sequence.s
                tAnimation = tAnimation.concatenating(sequence.t)
            } else {
                let sequence = world.tSequence[oldState]  // undo old state
                animationStatus = "un-" + sequence.s
                tAnimation = tAnimation.concatenating(sequence.t.inverted())
            }

//            print("\(animationStatus)")
//            tAnimation.print()

            if (newState == world.sequenceStart) {
                animationStatus += " / At Source"
            } else if (newState == world.sequenceEnd) {
                animationStatus += " / At Target"
            }
        }
    }
}

//// Canvas
//Rectangle()
//    .fill(Color.white)
//    .frame(width: canvasRect.size.width, height: canvasRect.size.height)
//    .position(x: canvasRect.midX, y: canvasRect.midY)
//    .onAppear {
//        let outerRect = CGRect(size: canvasRect.size)
//        print(outerRect)
//        let innerRect = CGRect(size: geoReader.size)
//        print(innerRect)
//        let fittedRect = innerRect.fit(rect: outerRect)
//        print(innerRect)
//        let scale = fittedRect.size.width / innerRect.size.width
//        print(scale)
//        let tx = fittedRect.minX - outerRect.minX
//        let ty = fittedRect.minY - outerRect.minY
//
//        var t = CGAffineTransform.identity
//        t = t.concatenating(CGAffineTransform(scaleX: scale, y: scale))
//        t = t.concatenating(CGAffineTransform(translationX: tx, y: ty))
//        t = t.concatenating(CGAffineTransform(translationX: canvasRect.minX, y: canvasRect.minY))
//
//        tCanvas = t
//        geoRect = CGRect(size: geoReader.size).applying(tCanvas)
//    }
//
//// GeoRect
//Rectangle()
//    .fill(Color.gray)
//    .frame(width: geoRect.size.width, height: geoRect.size.height)
//    .position(x: geoRect.midX, y: geoRect.midY)
//drawTickMark("tl", ┌canvasRect)
//    .stroke(Color.red, lineWidth: 2)
//drawTickMark("br", ┘canvasRect)
//    .stroke(Color.yellow, lineWidth: 2)


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

func drawTickMark(_ corner:String, _ origin:CGPoint, size:Int=20) -> Path {
    let primeX:CGFloat
    let primeY:CGFloat

    let size = CGFloat(size)
    switch corner {
    case "tl":
        primeX = origin.x + size
        primeY = origin.y + size

    case "br":
        primeX = origin.x - size
        primeY = origin.y - size

    default:
        primeX = origin.x
        primeY = origin.y
    }

    let extentX = CGPoint(x: primeX, y: origin.y)
    let extentY = CGPoint(x: origin.x, y: primeY)

    var path = Path()
    path.move(to: origin)
    path.addLine(to: extentX)
    path.move(to: origin)
    path.addLine(to: extentY)

    return path
}
