//
//  ContentView.swift
//  Kittek
//
//  Created by Vitalii on 21.04.2026.
//

import SwiftUI

#if os(iOS)
import AudioToolbox
#endif

struct ContentView: View {
    @State private var game = KittenGame.newLevel()
    @State private var reaction: KittenReaction = .idle
    @State private var draggingFood: Food?
    @State private var dragLocation: CGPoint?
    @State private var eyePhase: CGFloat = 0
    @State private var confettiSeed = 0

    var body: some View {
        GeometryReader { proxy in
            let board = GameBoardMetrics(size: proxy.size)

            ZStack {
                Color.black.ignoresSafeArea()

                ZStack {
                    Image("Test_Background 1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: board.width, height: board.height)
                        .clipped()

                    kittenLayer(board: board)

                    targetLayer(board: board)
                    bottomFoodLayer(board: board)

                    topControls(board: board)

                    if game.isComplete {
                        completionLayer(board: board)
                    }
                }
                .frame(width: board.width, height: board.height)
                .clipShape(RoundedRectangle(cornerRadius: board.cornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.45), radius: 22, x: 0, y: 14)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
            .onAppear {
                startEyeAnimation()
            }
        }
    }

    private func kittenLayer(board: GameBoardMetrics) -> some View {
        ZStack {
            Image(reaction.imageName(isComplete: game.isComplete))
                .resizable()
                .frame(width: board.width, height: board.height)

            if reaction == .idle && !game.isComplete {
                Image("Test_Kitten_Eyeballs 1")
                    .resizable()
                    .frame(width: board.kittenEyeLayerSize.width, height: board.kittenEyeLayerSize.height)
                    .position(board.kittenEyeLayerCenter)
                    .opacity(0.95)

                Image("Test_Kitten_Pupils 1")
                    .resizable()
                    .frame(width: board.kittenEyeLayerSize.width, height: board.kittenEyeLayerSize.height)
                    .position(
                        x: board.kittenEyeLayerCenter.x + sin(eyePhase) * board.width * 0.014,
                        y: board.kittenEyeLayerCenter.y + cos(eyePhase * 0.7) * board.width * 0.007
                    )
                    .animation(.easeInOut(duration: 1.1), value: eyePhase)

                Image("Test_Kitten_Eyelids 1")
                    .resizable()
                    .frame(width: board.kittenEyeLayerSize.width, height: board.kittenEyeLayerSize.height)
                    .position(board.kittenEyeLayerCenter)
                    .opacity(0.95)
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.75), value: reaction)
    }

    private func targetLayer(board: GameBoardMetrics) -> some View {
        ForEach(Array(game.targets.enumerated()), id: \.element.id) { index, food in
            let center = board.targetCenter(at: index)
            let matched = game.matchedFoods.contains(food)
            Image(matched ? food.guessedAssetName : food.shapeAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: board.targetSize.width, height: board.targetSize.height)
                .saturation(matched ? 1 : 0.15)
                .brightness(matched ? 0 : -0.18)
                .scaleEffect(matched ? 1.07 : 1)
                .position(center)
                .animation(.spring(response: 0.32, dampingFraction: 0.72), value: matched)
        }
    }

    private func bottomFoodLayer(board: GameBoardMetrics) -> some View {
        ForEach(Array(game.bottomFoods.enumerated()), id: \.element.id) { index, food in
            let isUsed = game.matchedFoods.contains(food)
            let isDragging = draggingFood == food
            let center = board.bottomCenter(at: index, count: game.bottomFoods.count)

            Image(food.circleAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: board.foodSize, height: board.foodSize)
                .opacity(isUsed ? 0 : (isDragging ? 0.72 : 1))
                .scaleEffect(isDragging ? 1.08 : 1)
                .position(isDragging ? (dragLocation ?? center) : center)
                .zIndex(isDragging ? 10 : 2)
                .gesture(
                    DragGesture(minimumDistance: 2, coordinateSpace: .local)
                        .onChanged { value in
                            guard !isUsed, !game.isComplete else { return }
                            if draggingFood == nil {
                                draggingFood = food
                            }
                            dragLocation = value.location
                        }
                        .onEnded { value in
                            guard !isUsed, !game.isComplete else {
                                clearDrag()
                                return
                            }
                            resolveDrop(food: food, location: value.location, board: board)
                        }
                )
                .animation(.spring(response: 0.30, dampingFraction: 0.74), value: draggingFood)
                .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isUsed)
        }
    }

    private func topControls(board: GameBoardMetrics) -> some View {
        HStack {
            Button {
                resetLevel()
            } label: {
                Image("pauseButton 2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: board.controlSize, height: board.controlSize)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                resetLevel()
            } label: {
                Image("levelButton 2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: board.controlSize, height: board.controlSize)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, board.width * 0.08)
        .position(board.point(x: 0.50, y: 0.065))
    }

    private func completionLayer(board: GameBoardMetrics) -> some View {
        ZStack {
            Color.black.opacity(0.34)
                .ignoresSafeArea()

            ConfettiView(seed: confettiSeed)
                .allowsHitTesting(false)

            VStack(spacing: board.width * 0.04) {
                Spacer()

                HStack(spacing: board.width * 0.09) {
                    Button {
                        resetLevel()
                    } label: {
                        Image("reloadButton 2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: board.actionButtonSize, height: board.actionButtonSize)
                    }
                    .buttonStyle(.plain)

                    Button {
                        resetLevel()
                    } label: {
                        Image("playButton 2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: board.actionButtonSize, height: board.actionButtonSize)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, board.height * 0.07)
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 1.02)))
    }

    private func resolveDrop(food: Food, location: CGPoint, board: GameBoardMetrics) {
        guard let targetIndex = board.hitTargetIndex(for: location, targetCount: game.targets.count) else {
            showReaction(.sad)
            clearDrag()
            return
        }

        let targetFood = game.targets[targetIndex]
        if targetFood == food {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                _ = game.matchedFoods.insert(food)
            }
            showReaction(.happy)

            if game.isComplete {
                completeLevel()
            }
        } else {
            showReaction(.sad)
        }

        clearDrag()
    }

    private func showReaction(_ newReaction: KittenReaction) {
        reaction = newReaction
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            if !game.isComplete {
                reaction = .idle
            }
        }
    }

    private func completeLevel() {
        reaction = .victory
        confettiSeed += 1
        playVictorySound()
    }

    private func resetLevel() {
        withAnimation(.easeInOut(duration: 0.25)) {
            game = KittenGame.newLevel()
            reaction = .idle
            clearDrag()
        }
    }

    private func clearDrag() {
        draggingFood = nil
        dragLocation = nil
    }

    private func startEyeAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.45, repeats: true) { _ in
            Task { @MainActor in
                guard reaction == .idle, !game.isComplete else { return }
                eyePhase += .pi / 2
            }
        }
    }

    private func playVictorySound() {
        #if os(iOS)
        AudioServicesPlaySystemSound(1025)
        #endif
    }
}

private struct GameBoardMetrics {
    private let sourceSize = CGSize(width: 670, height: 1453)
    let width: CGFloat
    let height: CGFloat

    init(size: CGSize) {
        let aspect = sourceSize.width / sourceSize.height
        let maxWidth = min(size.width, size.height * aspect)
        width = maxWidth
        height = maxWidth / aspect
    }

    var cornerRadius: CGFloat { max(0, width * 0.035) }
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

private struct KittenGame {
    let targets: [Food]
    let bottomFoods: [Food]
    var matchedFoods: Set<Food>

    var isComplete: Bool {
        matchedFoods.count == targets.count
    }

    static func newLevel() -> KittenGame {
        let targets = Array(Food.allCases.shuffled().prefix(3))
        let distractors = Food.allCases.filter { !targets.contains($0) }.shuffled().prefix(2)
        let bottomFoods = (targets + distractors).shuffled()
        return KittenGame(targets: targets, bottomFoods: bottomFoods, matchedFoods: [])
    }
}

private enum KittenReaction: Equatable {
    case idle
    case happy
    case sad
    case victory

    func imageName(isComplete: Bool) -> String {
        if isComplete {
            return "Test_Kitten_Victory 1"
        }

        switch self {
        case .idle:
            return "Test_Kitten 1"
        case .happy:
            return "Test_Kitten_Happy 1"
        case .sad:
            return "Test_Kitten_Sad 1"
        case .victory:
            return "Test_Kitten_Victory 1"
        }
    }
}

private enum Food: String, CaseIterable, Identifiable {
    case strawberry = "Strawberry"
    case banana = "Banana"
    case apple = "Apple"
    case raspberry = "Raspberry"
    case kiwi = "Kiwi"

    var id: String { rawValue }
    var shapeAssetName: String { "\(rawValue)_shape 1" }
    var guessedAssetName: String { "\(rawValue)_guessed 1" }
    var circleAssetName: String { "\(rawValue)_circle 1" }
}

private struct ConfettiView: View {
    let seed: Int

    private var pieces: [ConfettiPiece] {
        (0..<42).map { index in
            ConfettiPiece(
                id: index,
                x: CGFloat((index * 37 + seed * 11) % 100) / 100,
                delay: Double(index % 9) * 0.11,
                size: CGFloat(6 + (index % 5) * 3),
                color: [.pink, .yellow, .mint, .orange, .cyan, .purple][index % 6]
            )
        }
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let elapsed = timeline.date.timeIntervalSinceReferenceDate

                for piece in pieces {
                    let progress = CGFloat((elapsed + piece.delay).truncatingRemainder(dividingBy: 2.4) / 2.4)
                    let y = size.height * progress
                    let wobble = sin(progress * .pi * 6 + CGFloat(piece.id)) * 18
                    let rect = CGRect(
                        x: size.width * piece.x + wobble,
                        y: y - 16,
                        width: piece.size,
                        height: piece.size * 0.55
                    )

                    context.opacity = 1 - max(0, progress - 0.76) * 2.2
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: 2),
                        with: .color(piece.color)
                    )
                }
            }
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id: Int
    let x: CGFloat
    let delay: Double
    let size: CGFloat
    let color: Color
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
