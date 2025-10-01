extends Node
class_name GameManager

@export var world: Node
@export var player: Player
@export var map_generator: MapGenerator

@export var coins_count_label: Label
@export var general_ui: Control
@export var win_ui: Control
@export var lose_ui: Control

@onready var _coin_res = preload("res://scenes/coin.tscn")
@onready var _level_exit_res = preload("res://scenes/level_exit.tscn")

var coins: Array[Coin]
var level_exits: Array[LevelExit]
var _coins_collected: int = 0

func _ready() -> void:
	start_game()

func start_game() -> void:
	map_generator.clear_map()
	map_generator.generate_map()

	# wait for deffered generation to complete
	await get_tree().process_frame

	player.show()
	player.process_mode = Node.PROCESS_MODE_ALWAYS

	general_ui.show()
	win_ui.hide()
	lose_ui.hide()
	
	_coins_collected = 0
	coins_count_label.text = "Coins: " + str(_coins_collected)

func end_game() -> void:
	player.process_mode = Node.PROCESS_MODE_DISABLED
	general_ui.hide()
	if player.is_alive: # lose
		win_ui.hide()
		lose_ui.show()
	elif _coins_collected == GlobalVariables.coins_to_win: # win
		win_ui.show()
		lose_ui.hide()
	else: # error
		print_debug("end_game error")

func exit() -> void:
	get_tree().quit()

func change_level() -> void:
	map_generator.clear_map()
	for level_exit in level_exits:
		if level_exit:
			level_exit.queue_free()
	for coin in coins:
		if coin:
			coin.queue_free()
	map_generator.generate_map()

func increase_coins() -> void:
	_coins_collected += 1
	coins_count_label.text = "Coins: " + str(_coins_collected)
	
	if _coins_collected >= GlobalVariables.coins_to_win:
		end_game()

func get_player() -> CharacterBody2D:
	return player

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
