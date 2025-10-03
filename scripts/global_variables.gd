extends Node

# Coins
const coins_to_win: int = 10
const coins_per_level: int = 3
const coin_spawn_chance: float = 0.01

# Enemies
const enemies_per_level: int = 7
const enemy_spawn_chance: float = 0.01
const enemy_spawn_distance_from_player: float = 100.0

const enemy_move_speed: float = 30
const enemy_damage: float = 20.0
const enemy_attack_cooldown: float = 2.0
const enemy_attack_knockback: float = 120.0

const enemy_follow_distance: float = 80.0
const enemy_stop_follow_distance: float = 100.0

# Player
const player_move_speed: float = 60.0
const player_max_health: float = 100.0
const player_dash_cooldown: float = 1.0
const player_dash_time: float = 0.25
const player_invincible_time: float = 1.1

# Game state
var game_ended: bool = false
var coins_collected: int = 0
