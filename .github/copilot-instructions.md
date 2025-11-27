# Copilot Instructions for Starship Survivors (Godot 4.5)

## Project Overview
- **Genre**: 2D top-down space survivor-like game (similar to Vampire Survivors)
- **Engine**: Godot 4.5 with Mobile features enabled
- **Gameplay Loop**: Player controls a spaceship, survives enemy waves, collects experience orbs, levels up to unlock/upgrade weapons
- **Entry Point**: `LoginScreen.tscn` (profile system) → `TitleScreen/menu.tscn` (main menu) → `World/world.tscn` (gameplay)

## Architecture & Data Flow

### Autoload Singletons (Global Managers)
Critical pattern: Six autoloaded nodes provide global state management (see `project.godot`):
- `UpgradeDb`: Upgrade definitions and stat application logic
- `WeaponRegistry`: Centralized weapon stats system (avoids duplicating level data in player.gd)
- `Talo`: Third-party analytics/leaderboard integration
- `SkinManager`: Player ship selection and persistence
- `LocalProfile`: Profile/leaderboard system (user:// save files)
- `TitleMusicPlayer`: Persistent music control across scenes

**Why this matters**: Always check autoloads first when adding global features. Access via `get_node("/root/AutoloadName")` or direct name (e.g., `SkinManager.equipped`).

### Weapon System Architecture
**WeaponRegistry Pattern** (introduced to centralize stats):
- `weapon_registry.gd`: Single source of truth for weapon level progression
- Each weapon has 8 levels defined with stats (damage, speed, ammo, hp/pierce, etc.)
- Player calls `WeaponRegistry.get_weapon_stats("plasma", level)` to retrieve current stats
- Upgrade descriptions also live in registry to keep UI in sync with mechanics
- **Critical**: When balancing weapons, edit `weapon_registry.gd` ONLY, not player.gd

**Player Weapon Integration**:
- `player.gd` stores current weapon levels and timers
- `Player/Attack/` contains weapon projectile scenes
- Weapons fire via timer system: cooldown timer → set ammo count → attack timer drains ammo
- `additional_attacks` stat increases ammo per volley without changing base weapon stats

### Upgrade System Flow
1. **Level Up**: `player.gd` → `levelup()` → displays 3 random upgrade options
2. **Selection**: `item_option.gd` calls `player.upgrade_character(upgrade_id)`
3. **Application**: 
   - Weapons: Parse `"plasma3"` → set level, pull stats from `WeaponRegistry`
   - Stat upgrades: `UpgradeDb.apply_upgrade_to_player()` modifies player properties
4. **Prerequisite Chain**: Each upgrade has prerequisites array (e.g., `"plasma2"` requires `["plasma1"]`)

### Enemy Spawning & Difficulty
**Dynamic Difficulty System** (`difficulty_manager.gd`):
- Tracks player performance: damage taken rate, kill rate, consecutive hits
- Adjusts `spawn_rate_multiplier` and `enemy_count_multiplier` every 5 seconds
- Formula: `performance_score` based on damage/kills → smoothly lerp difficulty (0.1x to 2.5x)
- **Why**: Maintains engagement without hard difficulty modes; player skill directly scales challenge

**Spawner Logic** (`enemy_spawner.gd`):
- Uses `Spawn_info` resources to define time windows and enemy types
- Smart repositioning: teleports off-screen enemies ahead of player when pool > 12 enemies behind
- Max 150 enemies; stops spawning and repositions instead when cap reached
- Spawns biased toward player's movement direction (predictive spawn placement)

### Memory Management Patterns
**Projectile Pooling**:
- `player.gd` tracks `active_projectile_count` (max 200)
- Periodic cleanup removes invalid projectiles every 60 frames (or 15 if high count)
- Plasma weapon prewarmed in `_ready()` to avoid first-fire stutter

**Enemy Array Cleanup**:
- `enemy_close` and `targeted_enemies` arrays filtered for `is_instance_valid()` checks
- Prevents memory leaks from queued enemies

## Critical GDScript Patterns

### Node Group Communication
```gdscript
# Standard pattern for finding managers/singletons
var player = get_tree().get_first_node_in_group("player")
difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
```
Groups used: `player`, `enemy`, `loot`, `attack`, `boss`, `difficulty_manager`

### Signal-Based Array Management
```gdscript
# Enemy/projectiles emit when dying
signal remove_from_array(object)
# Parent connects to decrement counters
enemy_spawn.remove_from_array.connect(_on_enemy_removed)
```

### Deferred Child Addition
Always use `call_deferred("add_child", node)` when spawning from physics callbacks or signals to avoid mid-frame tree modifications.

### Physics Collision Layers
Defined in `project.godot`:
- Layer 1: World (rocks/obstacles)
- Layer 2: Player
- Layer 3: Enemy  
- Layer 4: Loot

Bosses disable layer 2 collision to avoid blocking player movement.

## Developer Workflows

### Adding New Weapons
1. Create weapon scene in `Player/Attack/` (extend `BaseWeaponProjectile` if available)
2. Add weapon definition to `weapon_registry.gd` WEAPONS dict:
   - Define 8 levels with progressive stats
   - Add level descriptions for UI
   - Set base cooldown
3. Add weapon state vars to `player.gd` (level, ammo, timers)
4. Add timer nodes to `player.tscn` (cooldown + attack timers)
5. Connect timer signals in `player.gd`
6. Implement firing logic in `player.gd`
7. Add starting weapon option to `skin_manager.gd` if ship-specific

### Adding Non-Weapon Upgrades
1. Add upgrade data to `upgrade_db.gd` UPGRADES dict (icon, display name, details, prerequisite)
2. Add effect to UPGRADE_EFFECTS dict (stat name, value per level)
3. `apply_upgrade_to_player()` automatically handles stat application via match statement
4. For new stat types: add property to `player.gd` and new match case in `apply_upgrade_to_player()`

### Testing Performance Changes
- Monitor `active_projectile_count` and `active_enemy_count` via print statements
- Check cleanup frequency in `_physics_process` (adjusts automatically when counts high)
- Test difficulty scaling by forcing low/high `performance_score` in `difficulty_manager.gd`

### Debugging Enemy Spawning
- Check `enemy_spawner.gd` time-based spawn windows in `spawns` array
- Verify difficulty manager multipliers via `get_spawn_rate_multiplier()`
- Use `_count_far_behind_enemies()` to see if repositioning triggers
- Ensure enemies have `remove_from_array` signal connected

## Skin/Profile System Integration
- **Skins** (`SkinManager`): Stored in `user://skins.save`, determines starting weapon
- **Profiles** (`LocalProfile`): Stored in `user://profiles/`, tracks leaderboard scores per profile+ship combo
- Leaderboard shows top 10 scores filtered by current profile and equipped ship
- LoginScreen validates profile name (3-20 chars) before accessing main menu

## Common Pitfalls
1. **Weapon stats**: Don't hardcode damage/speed in player.gd, use `WeaponRegistry`
2. **Autoloads**: Reference by exact name from project.godot, not scene paths
3. **Groups**: Always use `get_first_node_in_group()` not `get_node()` for managers
4. **Signals**: Connect enemy/projectile removal signals or memory leaks occur
5. **Timer cooldowns**: Apply `spell_cooldown` modifier via `WeaponRegistry.get_effective_cooldown()`, not manual math
6. **Deferred calls**: Use when spawning from signals/physics to avoid crashes
7. **Experience multiplier**: Applied in `calculate_experience()` before leveling logic

## Key Files Reference
- `Player/player.gd` (806 lines): Core gameplay state, weapon firing, upgrade application
- `Utility/weapon_registry.gd`: Single source of truth for weapon balance
- `Utility/upgrade_db.gd`: Upgrade definitions and stat application
- `Utility/difficulty_manager.gd`: Dynamic difficulty scaling algorithm
- `Utility/enemy_spawner.gd`: Spawn timing, repositioning, difficulty integration
- `Enemy/enemy.gd`: Enemy movement with obstacle avoidance and speed scaling
- `World/world.gd`: Scene controller, pause menu, background randomization

---

*Last updated: Based on analysis of codebase structure and autoload singleton architecture*