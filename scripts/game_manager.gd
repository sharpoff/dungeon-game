extends Node
class_name GameManager

@export var world: Node
@export var map_generator: MapGenerator

@export var general_ui: Control
@export var win_ui: Control
@export var lose_ui: Control
@export var save_found: Control
@export var loading_screen: Control

@export var coins_label: Label
@export var health_label: Label

@onready var _coin_res = preload("res://scenes/coin.tscn")
@onready var _level_exit_res = preload("res://scenes/level_exit.tscn")
@onready var _enemy_res = preload("res://scenes/enemy.tscn")
@onready var _player_res = preload("res://scenes/player.tscn")
@onready var _tile_map_res = preload("res://scenes/tilemap.tscn")

const save_file_path = "user://game_save.json"

var player: Player

func _ready() -> void:
	if _save_file_exists():
		_hide_all_ui()
		save_found.show()
	else:
		map_generator.tile_map = _tile_map_res.instantiate()
		world.add_child.call_deferred(map_generator.tile_map)
		start_game()

func _process(_delta: float) -> void:
	if !GlobalVariables.game_ended and player and player.health <= 0:
		end_game()

func start_game() -> void:
	GlobalVariables.game_ended = false
	if player:
		player.queue_free()
	create_player(Vector2())
	await get_tree().process_frame # wait for deffered player creation
	
	GlobalVariables.coins_collected = 0
	coins_label.text = "Coins: " + str(GlobalVariables.coins_collected)
	
	change_level()

func end_game() -> void:
	player.set_input(false)
	player.set_visiblity(false)
	
	_hide_all_ui()
	general_ui.show()
	if GlobalVariables.coins_collected == GlobalVariables.coins_to_win: # win
		win_ui.show()
	else: # lose
		lose_ui.show()
	
	GlobalVariables.game_ended = true

func exit() -> void:
	get_tree().quit()

func change_level() -> void:
	_hide_all_ui()
	loading_screen.show()

	_clear_level()
	var spawn_position = map_generator.generate_map()
	player.position = spawn_position
	player.set_input(false)

	await get_tree().process_frame # wait for deffered calls to end
	await get_tree().create_timer(1).timeout
	
	_hide_all_ui()
	general_ui.show()
	player.set_input(true)
	player.set_visiblity(true)

func _clear_level():
	map_generator.clear_map()
	for level_exit in get_tree().get_nodes_in_group("level_exit"):
		if level_exit:
			level_exit.queue_free()
	for coin in get_tree().get_nodes_in_group("coin"):
		if coin:
			coin.queue_free()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy:
			enemy.queue_free()

func increase_coins() -> void:
	if GlobalVariables.game_ended:
		return
	
	GlobalVariables.coins_collected += 1
	_update_ui()
	
	if GlobalVariables.coins_collected >= GlobalVariables.coins_to_win:
		end_game()

func _update_ui() -> void:
	coins_label.text = "Coins: " + str(GlobalVariables.coins_collected)
	if player:
		health_label.text = "Health: " + str(player.health)

func change_health_ui(_health: int) -> void:
	if GlobalVariables.game_ended:
		return
	
	_update_ui()

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
	world.add_child.call_deferred(coin)

func create_level_exit(pos: Vector2i) -> void:
	var level_exit: LevelExit = _level_exit_res.instantiate()
	level_exit.game_manager = self
	level_exit.position = pos
	world.add_child.call_deferred(level_exit)

func create_enemy(pos: Vector2i) -> void:
	var enemy: Enemy = _enemy_res.instantiate()
	enemy.position = pos
	world.add_child.call_deferred(enemy)

func _hide_all_ui():
	win_ui.hide()
	lose_ui.hide()
	loading_screen.hide()
	save_found.hide()

func save_game() -> void:
	var save_file = FileAccess.open(save_file_path, FileAccess.WRITE)
	# save game state
	var game_data = {
		"game_state": true,
		"game_ended": GlobalVariables.game_ended,
		"coins_collected": GlobalVariables.coins_collected,
	}
	save_file.store_line(JSON.stringify(game_data))
	
	# save all persist nodes by calling save method
	var persist_nodes = get_tree().get_nodes_in_group("persist")
	for node in persist_nodes:
		if node.scene_file_path.is_empty():
			print_debug("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		if !node.has_method("save"):
			print_debug("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		var node_data = node.call("save")
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)

func _save_file_exists() -> bool:
	return FileAccess.file_exists(save_file_path)

func load_game() -> void:
	if not _save_file_exists():
		print_debug("load_game failed. no save file exists.")
		return
	
	print_debug("loading game")
	
	# TODO: revert current game state, if persist objects exist
	
	var save_file = FileAccess.open(save_file_path, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		
		var result = json.parse(json_string)
		if not result == OK:
			print_debug("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var node_data: Dictionary = json.data
		
		# load game state
		if "game_state" in node_data:
			GlobalVariables.game_ended = node_data["game_ended"]
			GlobalVariables.coins_collected = node_data["coins_collected"]
			continue # skip node creation
		
		# instantiate an object if it has "filename" field
		if node_data.get("filename"):
			var new_object: Node = load(node_data["filename"]).instantiate()
			print_debug("loading %s file" % node_data["filename"])
			
			if new_object.has_method("load_game"):
				new_object.load_game(node_data, self)
			
			get_node(node_data["parent"]).add_child.call_deferred(new_object)

# general ui
func _on_save_exit_pressed() -> void:
	save_game()
	get_tree().change_scene_to_file("res://scenes/ui/menu_ui.tscn")

# save found ui
func _on_load_pressed() -> void:
	load_game()
	
	await get_tree().process_frame # wait for deffered calls to end
	player = get_tree().get_first_node_in_group("player")
	map_generator.tile_map = get_tree().get_first_node_in_group("tilemap")
	
	if !player or !map_generator.tile_map:
		print_debug("Failed to load game")
		get_tree().quit(-1)
	
	player.health_changed.connect(change_health_ui)

	_hide_all_ui()
	general_ui.show()
	_update_ui()

# save found ui
func _on_new_save_pressed() -> void:
	map_generator.tile_map = _tile_map_res.instantiate()
	world.add_child.call_deferred(map_generator.tile_map)
	start_game()
