extends Node
class_name GameManager

@export var world: Node
@export var map_generator: MapGenerator

@export var general_ui: Control
@export var win_ui: Control
@export var lose_ui: Control
@export var loading_screen: Control
@export var coins_label: Label
@export var health_label: Label

@onready var _coin_res = preload("res://scenes/coin.tscn")
@onready var _level_exit_res = preload("res://scenes/level_exit.tscn")
@onready var _enemy_res = preload("res://scenes/enemy.tscn")
@onready var _player_res = preload("res://scenes/player.tscn")

var player: Player
var coins: Array[Coin]
var level_exits: Array[LevelExit]
var enemies: Array[Enemy]
var _coins_collected: int = 0
var game_ended: bool = false

func _ready() -> void:
	start_game()

func _process(_delta: float) -> void:
	if player and player.health <= 0:
		end_game()

func start_game() -> void:
	game_ended = false
	if player:
		player.queue_free()
	create_player(Vector2())
	await get_tree().process_frame # wait for deffered player creation
	
	_coins_collected = 0
	coins_label.text = "Coins: " + str(_coins_collected)
	
	change_level()

func end_game() -> void:
	player.set_input(false)
	player.set_visiblity(false)

	general_ui.show()
	if _coins_collected == GlobalVariables.coins_to_win: # win
		win_ui.show()
		lose_ui.hide()
	else: # lose
		win_ui.hide()
		lose_ui.show()
	
	game_ended = true

func exit() -> void:
	get_tree().quit()

func change_level() -> void:
	loading_screen.show()

	_clear_level()
	var spawn_position = map_generator.generate_map()
	player.position = spawn_position
	player.set_input(false)

	general_ui.show()
	win_ui.hide()
	lose_ui.hide()
	
	await get_tree().process_frame # wait for deffered calls to end
	
	await get_tree().create_timer(1).timeout
	player.set_input(true)
	player.set_visiblity(true)
	loading_screen.hide()

func _clear_level():
	map_generator.clear_map()
	for level_exit in level_exits:
		if level_exit:
			level_exit.queue_free()
	for coin in coins:
		if coin:
			coin.queue_free()
	for enemy in enemies:
		if enemy:
			enemy.queue_free()

func increase_coins() -> void:
	if game_ended:
		return
	
	_coins_collected += 1
	coins_label.text = "Coins: " + str(_coins_collected)
	
	if _coins_collected >= GlobalVariables.coins_to_win:
		end_game()

func change_health_ui(health: int) -> void:
	if game_ended:
		return
	
	health_label.text = "Health: " + str(health)

func get_player() -> CharacterBody2D:
	return player

func create_player(pos: Vector2i) -> void:
	player = _player_res.instantiate()
	player.position = pos
	player.health = GlobalVariables.player_max_health
	player.health_changed.connect(change_health_ui)
	world.add_child.call_deferred(player)

func create_coin(pos: Vector2i) -> void:
	var coin: Coin = _coin_res.instantiate()
	coin.game_manager = self
	coin.position = pos
	coins.append(coin)
	world.add_child.call_deferred(coin)

func create_level_exit(pos: Vector2i) -> void:
	var level_exit: LevelExit = _level_exit_res.instantiate()
	level_exit.game_manager = self
	level_exit.position = pos
	level_exits.append(level_exit)
	world.add_child.call_deferred(level_exit)

func create_enemy(pos: Vector2i) -> void:
	var enemy: Enemy = _enemy_res.instantiate()
	enemy.game_manager = self
	enemy.position = pos
	enemies.append(enemy)
	world.add_child.call_deferred(enemy)

func save_game() -> void:
	var persist_nodes = get_tree().get_nodes_in_group("persist")
	for node in persist_nodes:
		pass
