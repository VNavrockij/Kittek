# Kittek

Kittek is a small SwiftUI matching game for iOS. The player drags fruit from the basket to the matching silhouettes at the top of the screen while the kitten reacts to correct and incorrect choices.

## Screenshots

<p>
  <img src="Resource/Simulator%20Screenshot%20-%20iPhone%2011%20Pro%20Max%20-%202026-04-21%20at%2011.25.43.png" width="180" alt="Kittek gameplay screen">
  <img src="Resource/Simulator%20Screenshot%20-%20iPhone%2011%20Pro%20Max%20-%202026-04-21%20at%2011.25.49.png" width="180" alt="Kittek drag and match interaction">
  <img src="Resource/Simulator%20Screenshot%20-%20iPhone%2011%20Pro%20Max%20-%202026-04-21%20at%2011.25.52.png" width="180" alt="Kittek feedback state">
  <img src="Resource/Simulator%20Screenshot%20-%20iPhone%2011%20Pro%20Max%20-%202026-04-21%20at%2011.26.00.png" width="180" alt="Kittek pause overlay">
  <img src="Resource/Simulator%20Screenshot%20-%20iPhone%2011%20Pro%20Max%20-%202026-04-21%20at%2011.26.06.png" width="180" alt="Kittek completed round">
</p>

## Features

- Drag-and-drop fruit matching gameplay.
- Animated kitten reactions for idle, happy, sad, and victory states.
- Highlighted target hints while dragging the correct fruit.
- Shake feedback for wrong drops.
- Short success and miss feedback messages.
- Pause overlay that stops the music without resetting the round.
- Background round melody and victory sound.
- Full-screen responsive layout based on the original art aspect ratio.

## Architecture

The project is organized around a simple MVC-style structure:

- `Models/` contains game data and enums, including `KittenGame`, `Food`, and reactions.
- `Controllers/` contains `GameController`, which owns round state, pause state, matching logic, feedback, and audio triggers.
- `Views/` contains SwiftUI view helpers such as board metrics, confetti, and shake animation.
- `Services/` contains `RoundMusicPlayer`, the generated background melody player.
- `ContentView.swift` renders the game screen and forwards user actions to the controller.

## Requirements

- Xcode 16 or newer.
- iOS target supported by the project settings.
- SwiftUI.

## Running

1. Open `Kittek.xcodeproj` in Xcode.
2. Select the `Kittek` scheme.
3. Run on an iPhone simulator or a physical iPhone.

## Gameplay

Match each fruit from the basket with its silhouette. Correct matches stay filled in, wrong drops trigger feedback, and completing all targets shows the victory state.
