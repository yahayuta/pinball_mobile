# Pinball Mobile

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

A feature-rich mobile pinball game built with Flutter and Flame/Forge2D. Experience realistic physics, engaging gameplay elements, and tilt controls on your mobile device.

## Features

-   **Realistic Physics**: Powered by `flame_forge2d` for authentic ball movement and collisions.
-   **Interactive Elements**:
    -   **Pop Bumpers**: Add bounce and score points.
    -   **Drop Targets**: Strategic targets to hit.
    -   **Slingshots**: Accelerate the ball for fast-paced action.
    -   **Rollover Lanes**: Skill shots for bonus points.
-   **Tilt Control**: Use your device's accelerometer to nudge the ball (powered by `sensors_plus`).
-   **Audio**: Immersive sound effects using `audioplayers`.
-   **Social Sharing**: Share your high scores with friends via `share_plus`.

## Gameplay Enhancements

-   **Tuned Launcher Lane**: Optimized wall layout for consistent ball entry into the playfield.

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
