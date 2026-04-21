import SwiftUI

struct GameBoardMetrics {
    private let sourceSize = CGSize(width: 670, height: 1453)
    let width: CGFloat
    let height: CGFloat

    init(size: CGSize) {
        let aspect = sourceSize.width / sourceSize.height
        let fillWidth = max(size.width, size.height * aspect)
        width = fillWidth
        height = fillWidth / aspect
    }

    var foodSize: CGFloat { width * 0.145 }
    var controlSize: CGFloat { width * 0.095 }
    var actionButtonSize: CGFloat { width * 0.15 }
    var targetSize: CGSize { CGSize(width: width * 0.20, height: width * 0.24) }
    var kittenEyeLayerSize: CGSize { CGSize(width: width * 0.423, height: width * 0.232) }
    var kittenEyeLayerCenter: CGPoint { point(x: 0.501, y: 0.405) }

    func point(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(x: width * x, y: height * y)
    }

    func targetCenter(at index: Int) -> CGPoint {
        let positions: [CGPoint] = [
            point(x: 0.25, y: 0.155),
            point(x: 0.50, y: 0.135),
            point(x: 0.75, y: 0.155)
        ]
        return positions[index]
    }

    func bottomCenter(at index: Int, count: Int) -> CGPoint {
        let availableWidth = width * 0.77
        let startX = (width - availableWidth) / 2
        let step = availableWidth / CGFloat(max(count - 1, 1))
        return CGPoint(x: startX + CGFloat(index) * step, y: height * 0.895)
    }

    func hitTargetIndex(for location: CGPoint, targetCount: Int) -> Int? {
        for index in 0..<targetCount {
            let center = targetCenter(at: index)
            let hitWidth = targetSize.width * 1.1
            let hitHeight = targetSize.height * 1.1
            let frame = CGRect(
                x: center.x - hitWidth / 2,
                y: center.y - hitHeight / 2,
                width: hitWidth,
                height: hitHeight
            )
            if frame.contains(location) {
                return index
            }
        }
        return nil
    }
}
