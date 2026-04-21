import SwiftUI

#if os(iOS)
import AudioToolbox
#endif

@MainActor
struct GameController {
    var game = KittenGame.newLevel()
    var reaction: KittenReaction = .idle
    var draggingFood: Food?
    var dragLocation: CGPoint?
    var eyePhase: CGFloat = 0
    var confettiSeed = 0
    var isPaused = false

    let musicPlayer = RoundMusicPlayer()

    var isRoundActive: Bool {
        !game.isComplete && !isPaused
    }

    mutating func startRoundMusicIfNeeded() {
        guard isRoundActive else { return }
        musicPlayer.start()
    }

    mutating func togglePause() {
        if isPaused {
            resume()
        } else {
            pause()
        }
    }

    mutating func pause() {
        guard !game.isComplete else { return }
        isPaused = true
        clearDrag()
        musicPlayer.stop()
    }

    mutating func resume() {
        guard !game.isComplete else { return }
        isPaused = false
        musicPlayer.start()
    }

    func stopRoundMusic() {
        musicPlayer.stop()
    }

    mutating func advanceEyeAnimation() {
        guard reaction == .idle, !game.isComplete, !isPaused else { return }
        eyePhase += .pi / 2
    }

    mutating func beginDragging(food: Food) {
        guard !game.matchedFoods.contains(food), !game.isComplete, !isPaused else { return }
        if draggingFood == nil {
            draggingFood = food
        }
    }

    mutating func updateDragLocation(_ location: CGPoint) {
        dragLocation = location
    }

    mutating func resolveDrop(food: Food, location: CGPoint, board: GameBoardMetrics) {
        guard !game.matchedFoods.contains(food), !game.isComplete, !isPaused else {
            clearDrag()
            return
        }

        guard let targetIndex = board.hitTargetIndex(for: location, targetCount: game.targets.count) else {
            showReaction(.sad)
            clearDrag()
            return
        }

        if game.targets[targetIndex] == food {
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

    mutating func resetReactionIfRoundContinues() {
        if !game.isComplete && !isPaused {
            reaction = .idle
        }
    }

    mutating func resetLevel() {
        withAnimation(.easeInOut(duration: 0.25)) {
            game = KittenGame.newLevel()
            reaction = .idle
            isPaused = false
            clearDrag()
        }
        musicPlayer.start()
    }

    mutating func clearDrag() {
        draggingFood = nil
        dragLocation = nil
    }

    private mutating func showReaction(_ newReaction: KittenReaction) {
        reaction = newReaction
    }

    private mutating func completeLevel() {
        reaction = .victory
        confettiSeed += 1
        musicPlayer.stop()
        playVictorySound()
    }

    private func playVictorySound() {
        #if os(iOS)
        AudioServicesPlaySystemSound(1025)
        #endif
    }
}
