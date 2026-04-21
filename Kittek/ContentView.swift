//
//  ContentView.swift
//  Kittek
//
//  Created by Vitalii on 21.04.2026.
//

import SwiftUI

struct ContentView: View {
    @State private var controller = GameController()

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

                    if controller.isPaused {
                        pauseOverlay(board: board)
                    }

                    if controller.game.isComplete {
                        completionLayer(board: board)
                    }
                }
                .frame(width: board.width, height: board.height)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            }
            .onAppear {
                startEyeAnimation()
                controller.startRoundMusicIfNeeded()
            }
            .onDisappear {
                controller.stopRoundMusic()
            }
            .onChange(of: controller.game.isComplete) { _, isComplete in
                if isComplete {
                    controller.stopRoundMusic()
                } else {
                    controller.startRoundMusicIfNeeded()
                }
            }
        }
        .ignoresSafeArea()
    }

    private func kittenLayer(board: GameBoardMetrics) -> some View {
        ZStack {
            Image(controller.reaction.imageName(isComplete: controller.game.isComplete))
                .resizable()
                .frame(width: board.width, height: board.height)

            if controller.reaction == .idle && !controller.game.isComplete {
                Image("Test_Kitten_Eyeballs 1")
                    .resizable()
                    .frame(width: board.kittenEyeLayerSize.width, height: board.kittenEyeLayerSize.height)
                    .position(board.kittenEyeLayerCenter)
                    .opacity(0.95)

                Image("Test_Kitten_Pupils 1")
                    .resizable()
                    .frame(width: board.kittenEyeLayerSize.width, height: board.kittenEyeLayerSize.height)
                    .position(
                        x: board.kittenEyeLayerCenter.x + sin(controller.eyePhase) * board.width * 0.014,
                        y: board.kittenEyeLayerCenter.y + cos(controller.eyePhase * 0.7) * board.width * 0.007
                    )
                    .animation(.easeInOut(duration: 1.1), value: controller.eyePhase)

                Image("Test_Kitten_Eyelids 1")
                    .resizable()
                    .frame(width: board.kittenEyeLayerSize.width, height: board.kittenEyeLayerSize.height)
                    .position(board.kittenEyeLayerCenter)
                    .opacity(0.95)
            }
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.75), value: controller.reaction)
    }

    private func targetLayer(board: GameBoardMetrics) -> some View {
        ForEach(Array(controller.game.targets.enumerated()), id: \.element.id) { index, food in
            let center = board.targetCenter(at: index)
            let matched = controller.game.matchedFoods.contains(food)
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
        ForEach(Array(controller.game.bottomFoods.enumerated()), id: \.element.id) { index, food in
            let isUsed = controller.game.matchedFoods.contains(food)
            let isDragging = controller.draggingFood == food
            let center = board.bottomCenter(at: index, count: controller.game.bottomFoods.count)

            Image(food.circleAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: board.foodSize, height: board.foodSize)
                .opacity(controller.game.isComplete || isUsed ? 0 : (isDragging ? 0.72 : 1))
                .scaleEffect(isDragging ? 1.08 : 1)
                .position(isDragging ? (controller.dragLocation ?? center) : center)
                .zIndex(isDragging ? 10 : 2)
                .gesture(
                    DragGesture(minimumDistance: 2, coordinateSpace: .local)
                        .onChanged { value in
                            guard !isUsed, !controller.game.isComplete, !controller.isPaused else { return }
                            controller.beginDragging(food: food)
                            controller.updateDragLocation(value.location)
                        }
                        .onEnded { value in
                            guard !isUsed, !controller.game.isComplete, !controller.isPaused else {
                                controller.clearDrag()
                                return
                            }
                            controller.resolveDrop(food: food, location: value.location, board: board)
                            scheduleReactionReset()
                        }
                )
                .animation(.spring(response: 0.30, dampingFraction: 0.74), value: controller.draggingFood)
                .animation(.spring(response: 0.34, dampingFraction: 0.82), value: isUsed)
        }
    }

    private func topControls(board: GameBoardMetrics) -> some View {
        HStack {
            Button {
                controller.togglePause()
            } label: {
                Image("pauseButton 2")
                    .resizable()
                    .scaledToFit()
                    .frame(width: board.controlSize, height: board.controlSize)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                controller.resetLevel()
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

    private func pauseOverlay(board: GameBoardMetrics) -> some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()

            VStack(spacing: board.width * 0.055) {
                Text("PAUSE")
                    .font(.system(size: board.width * 0.105, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)

                Button {
                    controller.resume()
                } label: {
                    Image("playButton 2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: board.actionButtonSize * 1.12, height: board.actionButtonSize * 1.12)
                }
                .buttonStyle(.plain)
            }
            .position(board.point(x: 0.50, y: 0.50))
        }
        .transition(.opacity)
        .zIndex(20)
    }

    private func completionLayer(board: GameBoardMetrics) -> some View {
        ZStack {
            Color.black.opacity(0.34)
                .ignoresSafeArea()

            ConfettiView(seed: controller.confettiSeed)
                .allowsHitTesting(false)

            VStack(spacing: board.width * 0.04) {
                Spacer()

                HStack(spacing: board.width * 0.09) {
                    Button {
                        controller.resetLevel()
                    } label: {
                        Image("reloadButton 2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: board.actionButtonSize, height: board.actionButtonSize)
                    }
                    .buttonStyle(.plain)

                    Button {
                        controller.resetLevel()
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

    private func scheduleReactionReset() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            controller.resetReactionIfRoundContinues()
        }
    }

    private func startEyeAnimation() {
        Timer.scheduledTimer(withTimeInterval: 1.45, repeats: true) { _ in
            Task { @MainActor in
                controller.advanceEyeAnimation()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
