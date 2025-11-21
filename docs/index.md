# Flutter Pinball Machine Emulation Game Development Plan

## 1. Project Overview
The project aims to create a realistic pinball machine emulation game using Flutter, implementing physics-based gameplay and authentic pinball machine mechanics.

## 2. Technical Stack
- **Framework**: Flutter
- **Language**: Dart
- **Rendering**: Flame
- **Physics Engine**: Forge2D (via `flame_forge2d`)
- **State Management**: Provider
- **Asset Management**: Flutter Assets
- **Audio**: `just_audio` package
- **Storage**: `shared_preferences` for high scores and settings

## 3. Core Features

### 3.1 Basic Game Mechanics
- Ball physics simulation: **Implemented (Forge2D)**
  - Further fine-tune restitution, friction, and density values for all bodies. `PinballBall` restitution has been slightly reduced to make the ball feel a bit heavier and more controllable.
  - Ball spin visualization improved. Ball's bounciness (restitution) and friction fine-tuned.
- Flipper mechanics: **Implemented (Forge2D)**
  - Flipper controls and positioning have been corrected:
    - Left flipper now correctly responds to left arrow key
    - Right flipper now correctly responds to right arrow key
  - Flipper physics and orientation improved for more natural gameplay. Flipper `motorSpeed` slightly reduced, `restitution` increased, `friction` slightly reduced.
  - Refine flipper power and responsiveness based on player feedback.
- Spring launcher mechanism: **Implemented (Forge2D, now utilizing a dedicated LauncherRamp for improved consistency)**
  - Refine launcher force and consistency, utilizing the dedicated `LauncherRamp` for improved guidance.
- Basic collision detection: **Implemented (Forge2D)**
  - Collision detection and response refined.
- Score tracking system: **Implemented (with combo system)**
  - **Skill Shots:** Reward players for successfully making a specific shot immediately after launching the ball.
  - **Combo System Expansion:** Introduce more complex combo sequences that involve hitting specific targets or ramps in order.
  - **Multiplier System:** Allow players to increase their score multiplier by completing certain objectives.

### 3.2 Pinball Elements
- Flippers (left and right): **Implemented**
- Bumpers: **Implemented**
  - **Pop Bumpers:** Add classic pop bumpers that push the ball away when hit, creating chaotic and exciting ball interactions.
- Targets: **Implemented**
  - **Drop Targets:** Implement banks of targets that drop down when hit. Completing a bank can trigger special modes or rewards.
- Ramps: **Implemented**
  - **Ramps and Loops:** Design more complex ramps and loops that can be chained together for high scores.
- Holes: **Implemented**
- Spinners: **Implemented**
  - **Spinners:** Add a spinning target that awards points for each rotation.
- Multi-ball system: **Implemented**
  - **Multi-Ball Modes:** Expand on the existing multi-ball feature with different modes (e.g., 2-ball, 3-ball, 6-ball chaos) and specific objectives during these modes.
- Ball save mechanism: **Implemented**
  - **Ball Save:** Implement a more robust ball save mechanic that can be earned or triggered by certain events.

### 3.3 Game Features
- High score system: **Implemented**
- Multiple game modes: Implemented (Basic)
- Sound effects and background music: **Implemented**
- Visual effects and animations: **Implemented (score popups, combo effects, bumper hit effects)**
- Tilt mechanism: Implemented (Basic)
  - **Tilt Mechanism:** Refine the tilt mechanism to be more forgiving but still prevent cheating.
- Power-ups and special events: **Implemented**

### 3.4 UI/UX Elements
- Main menu: **Implemented**
- Game HUD (score, balls remaining, etc.): **Implemented**
  - **Heads-Up Display (HUD):** Redesign the HUD to be more informative and visually appealing, showing the score, ball number, multipliers, and current objectives.
- Settings menu: **Implemented**
- High score board: **Implemented**
- Tutorial/Help screen: Implemented. The tutorial screen UI has been improved with consistent text styling.
- Sound controls: Implemented
- **Menu Redesign:** Overhaul the main menu and other UI screens to have a more modern and professional look.

## 4. Development Phases

### Phase 1: Project Setup and Basic Structure (Completed)
- Set up Flutter project with necessary dependencies.
- Implemented basic project architecture using `flame_forge2d`.

### Phase 2: Core Mechanics (Completed)
- Implemented basic ball physics, flipper mechanics, spring launcher (now with LauncherRamp), basic collision detection, and score tracking system using `flame_forge2d` with a combo system.

### Phase 3: Pinball Elements (Completed)
- Implemented bumpers, targets, ramps, holes, and spinners.
- Implemented multi-ball and ball save mechanisms.

### Phase 4: Game Features (In Progress)
- Basic visual effects and animations implemented, including score popups and combo effects.
- High score system implemented.
- Sound effects and background music implemented.
- Power-ups and special events implemented.

### Phase 5: UI/UX Development (Completed)
- Game HUD, Main menu, Settings menu, High score board, Sound controls and Tutorial/Help screen implemented.

### Phase 6: Polish and Testing (In Progress)
- Code cleanup and refactoring.
- Comprehensive testing.
- Performance optimization.

## 5. Technical Implementation Details

### 5.1 Physics Implementation
- Forge2D physics engine for realistic ball physics, flipper mechanics, and collision detection.
- Handles complex interactions between multiple objects.
- **Core Physics Bodies:** `PinballBall`, `PinballBumper`, and `PinballFlipper` have explicitly defined `density`, `restitution`, and `friction` values. `PinballBall` uses `bullet: true` for continuous collision detection. Flippers utilize a `RevoluteJoint` with significantly increased motor torque for more powerful and responsive action.
- **Interactive Components:** `DropTarget` uses a `PrismaticJoint`. `PinballHole` uses an `isSensor` fixture. The `Launcher`'s impulse force has been tuned for better ball launch speed.
- **Static Structures:** `GuideWall` uses `ChainShape` to define table boundaries.

### 5.2 Graphics and Animation
- Custom rendering using `Flame` for all game elements, with visual effects for scoring and combos.
- `PinballBumper` includes a `BumperHitEffect` triggered on activation and a glow effect when activated, indicating initial implementation of dynamic visual feedback.
- A `visual_effects.dart` file exists, suggesting further visual enhancements are planned or in progress.
- **Enhanced Visual Effects:**
  - Improve ball rendering (e.g., reflections, shadows).
  - Add more dynamic lighting effects for bumpers, targets, and special events.
  - Refine existing particle effects (score popups, combo effects, bumper hits).
  - Implement subtle camera shakes or zooms for impactful events.
  - Explore background and table texture improvements.

### 5.3 Game State Management
- Implemented state management using Provider.
- Handle game pause/resume
- Manage multiple ball states
- Track game progress and scores

### 5.4 Audio System
- Background music implementation.
- Sound effects for all interactions.
- Audio mixing and management.
- Volume controls and settings.
- Several components (e.g., `PinballFlipper`, `DropTarget`) demonstrate direct integration with an `AudioManager` for event-driven sound effects.
- The presence of `audio_manager.dart` and `assets/audio/` indicates a dedicated system for managing and playing game audio.
- A sound effect pool has been implemented in `AudioManager` to optimize playback and reduce overhead.
- Audio controls (music and SFX volume sliders) have been added to the settings screen.
- **Expanded Sound Effects:**
  - Add more varied sound effects for different types of collisions (e.g., ball hitting wood, metal, plastic).
  - Implement distinct sounds for each unique table component (ramps, holes, spinners).
  - Voice Callouts: Include voice callouts for important events like "Multi-ball!", "Jackpot!", and "High Score!".
- **Dynamic Music:**
  - Adaptive Soundtrack: Implement a dynamic music system where the soundtrack changes based on the game state (e.g., more intense music during multi-ball modes).
  - Themed Music: Compose unique soundtracks for each table theme.

## 6. Testing Strategy

### 6.1 Unit Testing
- Physics calculations
- Score tracking
- Game state management
- Collision detection

### 6.2 Integration Testing
- Game flow
- Menu navigation
- Save/load functionality
- Audio system integration

### 6.3 Performance Testing
- Frame rate monitoring
- Physics simulation stability
- Memory usage optimization
- Load time optimization

## 7. Asset Requirements

### 7.1 Graphics
- Table background
- Pinball elements (flippers, bumpers, etc.)
- UI elements
- Particle effects
- Animation sprites

### 7.2 Audio
- Background music
- Collision sounds
- Flipper sounds
- Special event sounds
- Menu sounds

## 8. Project Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.16.0
  flame_forge2d: ^0.19.0
  provider: ^6.1.1

  # Audio
  audioplayers: ^5.2.1
  shared_preferences: ^2.2.2
```

## 9. Deliverables
1. Functional pinball game application
2. Source code with documentation
3. Asset files (graphics and audio)
4. User manual
5. Technical documentation
6. Test reports

## 10. Future Enhancements

### 10.1 Advanced Features
- **Multi-Table Support:**
  - **Table Selection:** Allow players to choose from a variety of different tables, each with its own challenges and high scores.
- **Online & Social Features:**
  - **Online Leaderboards:** Implement global and friend-based leaderboards for each table.
  - **Achievements:** Add a system of achievements to reward players for completing specific challenges.
  - **Player Profiles:** Allow players to create profiles to track their stats, achievements, and high scores.
- **Customization:**
  - **Table Editor:** Create a user-friendly table editor that allows players to design and share their own pinball tables.
- **Themed Tables:**
  - **New Table Themes:** Create new tables with unique themes like "Space Adventure", "Jungle Expedition", or "Neon City". Each theme would have its own layout, graphics, and objectives.
  - **Customizable Tables:** Allow players to customize the appearance of the tables with different colors, materials, and decals.

### 10.2 Realism Enhancements
- **Advanced Player Techniques:**
  - **Nudging (Partially Implemented):** A basic nudge mechanic has been implemented. Players can press the `Shift` keys to apply a force to the ball. This is integrated with the tilt mechanism. Future work includes refining the nudge force and adding more visual/audio feedback.
  - **Advanced Flipper Skills (In Progress):** Refine the flipper physics to allow for advanced techniques like:
    - **Flipper Trapping:** Holding the ball on a raised flipper.
    - **Post Passing:** Transferring the ball from one flipper to the other by bouncing it off the post between the flippers.
    - **Dead Flipper Pass:** Passing the ball from one flipper to the other by letting it roll over the lowered flipper.
- **Complex Table Elements:**
  - **Captive Balls:** Add captive balls that are trapped in a small area and can be hit by the main ball for special rewards.
  - **Targets with Memory:** Implement target banks that need to be hit in a specific sequence to be completed.
  - **Vertical Up-Kickers (VUKs):** Add VUKs that kick the ball vertically to a higher playfield or a ramp.
  - **Subways:** Create underground passages that the ball can travel through, adding an element of surprise.
- **Deeper Scoring Rules:**
  - **Modes:** Introduce different "modes" that can be started by completing certain objectives. Each mode would have its own set of rules, objectives, and scoring, often tied to the table's theme.
  - **Storytelling:** Use the modes and the DMD to tell a simple story that unfolds as the player progresses through the game.
- **Realistic Physics and Audio:**
  - **Ball Spin and Friction (Implemented):** The ball's bounciness (restitution) and friction have been fine-tuned for more realistic interactions. Ball spin visualization has also been implemented to provide a visual cue for the ball's angular velocity.
  - **Mechanical Sounds (Implemented):** Dynamic volume and pitch adjustments have been implemented for sound effects based on impact force. Sound variations for repetitive events (e.g., bumper hits) have been added, and basic spatialization (left/right panning) has been implemented to enhance immersion.

## 11. Known Issues and Recent Fixes

### Recently Fixed:
- Flipper controls and positioning have been corrected:
  - Left flipper now correctly responds to left arrow key
  - Right flipper now correctly responds to right arrow key
  - Flipper physics and orientation improved for more natural gameplay. Flipper `motorSpeed` slightly reduced, `restitution` increased, `friction` slightly reduced.
- Ball spin visualization improved. Ball's bounciness (restitution) and friction fine-tuned.
- Collision detection and response refined.
- `PinballBall` restitution slightly reduced for a heavier feel.
- World gravity increased for faster gameplay.
- Sound effect pool implemented in `AudioManager` for optimized playback.
- Audio controls (music and SFX volume sliders) added to settings screen.
- `MenuButton` now includes a subtle scaling animation on press.
- `Launcher` component includes a visual charge bar.
- Main menu and table selection screen updated with custom `MenuButton` widget.
- Tutorial screen UI improved with consistent text styling.
- High score screen and leaderboard screen display top scores with improved visual styling.
- Multiplayer screen UI improved with custom styled buttons and text fields.
- Table editor screen UI improved with custom styled buttons and text fields, and custom tables displayed with delete functionality.
- Achievement screen displays achievements, progress, and unlocked status.
- Social screen UI improved with custom styled buttons.
- Re-introduced sprite loading and fixed asset paths.
- Fixed a number of compilation errors.
- Set the app to portrait mode.
- Adjusted the pinball table to fit the portrait layout.
- Fixed the flipper positions.
- Increased the launcher's power and adjusted its angle.
- Increased the ball's bounciness.

### Remaining Issues:
- Smooth gameplay at 60+ FPS needs further optimization (profiling CPU/GPU, rendering, physics overhead, asset loading/memory).
- Some physics behaviors could use additional refinement (e.g., further fine-tuning restitution, friction, density values for all bodies; monitoring for new physics glitches).
- Persistent issues with launching the Android emulator, preventing testing on this platform. (This is an environment setup issue, not a code bug.)
- Launcher consistency: In Progress. The launcher power has been increased, but further tuning is required to ensure the ball consistently enters the playfield.
- Web `KeyUp` event: A workaround is in place for an issue where the spacebar `KeyUp` event is not reliably detected on web builds.
- Visual assets (sprites) are placeholders and need to be replaced with final assets.
