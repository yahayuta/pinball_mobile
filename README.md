# Pinball Mobile

A realistic pinball machine emulation game built with Flutter and Flame.

## Project Status

This project is in active development. The core gameplay mechanics are complete, and the current focus is on enhancing the game feel through physics tuning, control refinement, and overall quality improvements. For a detailed roadmap, see the [PINBALL_ENHANCEMENT_PLAN.md](PINBALL_ENHANCEMENT_PLAN.md) and [PINBALL_QUALITY_ENHANCEMENT_PLAN.md](PINBALL_QUALITY_ENHANCEMENT_PLAN.md).

## Features

*   **Realistic Physics:** A physics-based gameplay experience powered by Forge2D.
*   **Classic Pinball Elements:**
    *   Player-controlled Flippers
    *   Pop Bumpers, Drop Targets, and Spinners
    *   Ramps and Loops
    *   Multi-ball modes
*   **Scoring System:**
    *   Real-time score tracking
    *   Combo system for skilled shots
    *   High score list saved locally
*   **Audio:**
    *   Dynamic sound effects for all pinball interactions.
    *   Background music.
    *   Volume controls in the settings menu.
*   **Multiple Tables:**
    *   Choose from different table layouts.
    *   Includes a "Space Adventure" themed table.
*   **Game Modes:**
    *   Work-in-progress support for multiple game modes.

## How to Play

*   **Launch Ball:** Press and hold the `Spacebar` to charge the launcher, and release to launch the ball.
*   **Flippers:**
    *   Use the `Left Arrow` key for the left flipper.
    *   Use the `Right Arrow` key for the right flipper.
*   **Tilt:** If you are playing on a mobile device, you can tilt the device to influence the ball's movement. Be careful not to tilt too much!

## Getting Started (for Developers)

To get started with this project, you will need to have Flutter installed on your system.

1.  Clone the repository:
    ```
    git clone https://github.com/yahayuta/pinball_mobile.git
    ```
2.  Navigate to the project directory:
    ```
    cd pinball_mobile
    ```
3.  Install the dependencies:
    ```
    flutter pub get
    ```
4.  Run the game:
    ```
    flutter run
    ```

## Project Structure

The project is structured as follows:

*   `lib/main.dart`: The main entry point of the application.
*   `lib/menu/`: Contains all the UI screens for the main menu, settings, high scores, etc.
*   `lib/game/`: Contains the core game logic.
    *   `lib/game/pinball_game.dart`: The main game class that manages the game loop and components.
    *   `lib/game/components/`: The different pinball table components (flippers, bumpers, etc.).
    *   `lib/game/forge2d/`: The Forge2D bodies that represent the physical objects in the game.
    *   `lib/game/tables/`: Definitions for the different pinball tables.
*   `assets/`: Contains all the game assets (images, audio, etc.).

## Contributing

Contributions are welcome! If you would like to contribute to this project, please feel free to open a pull request.
