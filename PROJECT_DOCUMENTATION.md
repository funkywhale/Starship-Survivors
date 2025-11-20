# Starship Survivors - Project Documentation

## 1. Project Overview

**Project Name:** Starship Survivors
**Godot Version:** 4.5.1 (as specified by user, project file indicates 4.5 features)
**Target Platform:** Web (WebGL/HTML5)

Starship Survivors is a top-down space shooter with roguelike elements, inspired by games like "Vampire Survivors". The player controls a starship, automatically firing a variety of weapons at incoming hordes of enemies. The primary goal is to survive for a set amount of time (currently 5 minutes). By defeating enemies, the player collects experience gems, levels up, and chooses from a selection of upgrades to enhance their ship and weapons.

## 2. Current State of the Project & Implemented Features

The project is in a playable state with a complete core game loop.

### 2.1. Player

The player is controlled via the `Player/player.gd` script.

*   **Movement:**
	*   Standard WASD controls for thrust and turning. The ship has inertia, making movement feel fluid.
	*   A "dash" ability (Spacebar) provides a short burst of speed on a cooldown.
*   **Combat:**
	*   Weapons fire automatically. The player's role is to navigate the ship to avoid enemies and collect items.
    *   The player has a health pool, and the game ends when it reaches zero.
*   **Progression:**
    *   The player gains experience by collecting gems dropped by defeated enemies.
    *   Upon leveling up, the game pauses, and the player is presented with three upgrade options.
	*   The experience required to level up scales with the player's current level.

### 2.2. Weapons

The player has access to three primary weapon systems, each with its own multi-level upgrade path:

*   **Pulse Laser:** The starting weapon. Fires projectiles at the nearest enemy.
*   **Rocket:** Launches rockets in the direction the player is moving.
*   **Plasma:** Creates damaging plasma fields around the player.

### 2.3. Enemies

Enemies are defined in the `Enemy/` directory.

*   **Behavior:** Enemies are driven by `Enemy/enemy.gd`. They have basic AI, moving directly towards the player.
*   **Variety:** The project includes several enemy types with different stats and sprites (e.g., `enemy_drone.tscn`, `enemy_battleship.tscn`).
*   **Spawning:** The `Utility/enemy_spawner.gd` script manages enemy spawning. It uses a time-based system, where different enemy types and quantities spawn as the game progresses. Enemies spawn just outside the player's view.

### 2.4. Upgrade System

The upgrade system is a core feature of the game.

*   **Upgrade Database:** The `Utility/upgrade_db.gd` script is an autoloaded singleton that acts as a centralized database for all available upgrades. It contains information about each upgrade, including its name, description, icon, and any prerequisites.
*   **Upgrade Types:**
    *   **Weapon Upgrades:** Improve existing weapons (e.g., more projectiles, higher damage).
	*   **Passive Upgrades:** Provide passive bonuses to the player's ship (e.g., increased armor, faster movement speed, higher fire rate).
*   **Leveling Up:** When the player levels up, the game randomly selects three available upgrades from the `UpgradeDb` and presents them to the player.

### 2.5. GUI

The game's UI provides the player with all necessary information:

*   **In-Game HUD:** Displays the player's health, current level and experience, a timer, and icons for collected weapons and upgrades.
*   **Level Up Screen:** A panel that appears when the player levels up, showing the available upgrade options.
*   **Game Over Screen:** A panel that appears when the player dies, showing whether they won or lost.

### 2.6. Audio

The project includes a variety of sound effects for actions like shooting, taking damage, and collecting items, as well as background music.

## 3. Future Implementation Suggestions

Here are some suggestions for implementing the requested features.

### 3.1. Player Login & Database Integration

For a web build, you have several options for implementing a player login system.

*   **Backend-as-a-Service (BaaS):** This is the most straightforward approach. Services like **Firebase Authentication**, **Supabase**, or **PlayFab** provide ready-to-use solutions for user authentication and data storage.
	*   **Implementation Steps:**
		1.  **Choose a BaaS provider:** Firebase is a popular choice with good documentation and a generous free tier.
		2.  **Set up your project:** Create a new project on the BaaS provider's website.
		3.  **Godot Integration:** Use a Godot plugin or the provider's REST API to communicate with the backend. For Firebase, there are several community-made plugins available on the Godot Asset Library.
		4.  **Create a Login Scene:** Design a new scene in Godot with UI elements for email/password input, registration, and login buttons.
		5.  **Implement API Calls:** In your login scene's script, make API calls to your BaaS provider to handle user registration and login.
		6.  **Store Player Data:** Once a player is logged in, you can use the BaaS provider's database (e.g., Firestore, Realtime Database) to store player data like high scores, unlocked achievements, or currency.

*   **Custom Backend:** You can create your own backend server using a framework like **Node.js with Express**, **Python with Django/FastAPI**, or **Go**.
	*   **Implementation Steps:**
		1.  **Develop the backend:** Create API endpoints for user registration, login, and data storage. You'll need to handle password hashing and session management (e.g., using JWTs).
        2.  **Deploy the backend:** Host your backend on a service like Heroku, AWS, or Google Cloud.
		3.  **Godot Integration:** Use Godot's `HTTPRequest` node to make calls to your backend API.

**Recommendation:** For ease of implementation and maintenance, a **BaaS solution like Firebase is highly recommended**, especially for an indie project.

### 3.2. Random Map Generation

To make the game more replayable, you can introduce random map generation with obstacles.

*   **Obstacle Scenes:** Create a few different obstacle scenes (e.g., asteroids, space debris). These should be `StaticBody2D` or `RigidBody2D` nodes so that the player and enemies can collide with them.
*   **Generation Algorithm:** In your `World/world.tscn` script (`world.gd`), you can implement a function to procedurally generate the map at the start of the game.
	*   **Simple Approach (Grid-based):**
		1.  Divide the game area into a grid.
		2.  Iterate through the grid cells and, with a certain probability, spawn an obstacle at the center of the cell.
		3.  To avoid unsolvable situations, ensure there's always a clear path for the player. You can use algorithms like **A*** to check for path availability.
    *   **Advanced Approach (Poisson Disc Sampling):** This algorithm generates points that are randomly distributed but no closer than a specified distance from each other. This creates a more natural-looking distribution of obstacles. There are Godot implementations of this algorithm available online.

### 3.3. Dynamic Enemy Spawning Based on Player Skill

The current enemy spawning system is based on time. To make it adapt to the player's skill level, you can introduce a "threat level" system.

*   **Defining Player Skill:**
	*   Track key performance indicators (KPIs) during a run, such as:
		*   Damage per second (DPS)
		*   Time to kill enemies
		*   Number of times the player takes damage
		*   Player's current level and upgrades
	*   You can also track performance across multiple runs (requires a database). For example, what is the player's average survival time?

*   **Threat Level System:**
	1.  **Calculate a "Threat Score":** At regular intervals (e.g., every 10 seconds), calculate a threat score based on the player's skill KPIs. A higher score means the player is doing well and can handle more difficult enemies.
    2.  **Adjust Spawning:** Modify the `Utility/enemy_spawner.gd` script to use this threat score to adjust its parameters:
        *   **Increase `enemy_num`:** Spawn more enemies.
        *   **Decrease `enemy_spawn_delay`:** Spawn enemies more frequently.
        *   **Spawn tougher enemies:** Instead of being purely time-based, the spawner can choose to spawn more difficult enemies if the threat score is high.
    3.  **Example Implementation:**
        *   In `enemy_spawner.gd`, add a `threat_level` variable (e.g., from 1 to 10).
        *   The `player.gd` script will be responsible for calculating the threat level and updating it in the spawner.
        *   The spawner will then use the `threat_level` to modify the `enemy_num` and `enemy_spawn_delay` variables in the `spawns` array.

By implementing these features, you can add significant depth and replayability to Starship Survivors.
