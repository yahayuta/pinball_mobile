# Pinball Mobile

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

A realistic pinball machine emulation game built with Flutter and Flame. Features physics-based gameplay, classic pinball elements like flippers, pop bumpers, and drop targets, and a score tracking system. This project is in active development.

## Features

-   **Realistic Physics**: Powered by `flame_forge2d` for authentic ball movement and collisions.
-   **Interactive Elements**:
    -   **Pop Bumpers**: Add bounce and score points.
    -   **Drop Targets**: Strategic targets to hit.
    -   **Slingshots**: Accelerate the ball for fast-paced action.
    -   **Rollover Lanes**: Skill shots for bonus points.
-   **Tilt Control**: Use your device's accelerometer to nudge the ball (powered by `sensors_plus`).
-   **Visual Overhaul**:
    -   **High-Quality Assets**: Chrome-reflective ball, neon pop bumpers, high-tech flippers, and vibrant playfield nebula background.
    -   **Procedural Neon Effects**: Advanced glowing rendering for walls and circular targets with dynamic hit feedback.
    -   **Optimized Scale**: Significantly increased component sizes for better visibility and playability on all screens.
    -   **Dynamic VFX**: Speed-sensitive ball trails and energetic particle impact effects.
-   **Audio**: Immersive sound effects using `audioplayers`.
-   **Social Sharing**: Share your high scores with friends via `share_plus`.

## Gameplay Enhancements

-   **Visual Overhaul**: Replaced placeholder graphics with professional-grade sprites and added vibrant VFX.
-   **Component Scaling**: Enlarged interactive elements (bumpers, drop targets, slingshots) to ensure they are clearly visible.
-   **Improved Mechanics**: Fixed bumper scoring logic and optimized collision detection.
-   **Tuned Launcher Lane**: Optimized wall layout for consistent ball entry into the playfield.

## Controls

-   **Flippers**: Tap the left or right side of the screen to control the corresponding flipper.
-   **Plunger**: Press and hold the bottom-right of the screen to charge the plunger, and release to launch the ball.
-   **Tilt**: Physically tilt your device to nudge the pinball table.

## Screenshots

| Main Menu | Gameplay |
| :---: | :---: |
| *(Add Screenshot)* | *(Add Screenshot)* |

## Getting Started

### Prerequisites

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.9.2 or higher)
-   Dart SDK
-   Android Studio / Xcode (for mobile emulation) or a physical device

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/yourusername/pinball_mobile.git
    cd pinball_mobile
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run the app:**

    ```bash
    flutter run
    ```

## Project Structure

The project follows a standard Flutter architecture:

-   `lib/game/`: Contains the core game logic, components (bumpers, walls, ball), and physics world.
-   `lib/main.dart`: Entry point of the application.
-   `pubspec.yaml`: Project configuration and dependencies.

## Contributing

Contributions are welcome! Please follow these steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add some amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Documentation

For detailed project information, development plans, and technical documentation, please refer to the [Project Documentation](docs/index.md).
