import Foundation

struct KittenGame {
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
