extends Node
class_name MapGenerator

@export var game_manager: GameManager

@export var map_size: Vector2i = Vector2i(40, 40)
@export_range(0, 100) var room_min_size: int = 5
@export_range(0, 100) var room_max_size: int = 8
@export_range(0, 100) var room_gen_iterations: int = 30 # how many times to try to generate a room

const ROOM_TERRAIN_SET: int = 0
const ROOM_TERRAIN: int = 0
const EMPTY_ATLAS_TILE = Vector2(8, 7)
const map_padding = 10 # padding for empty tiles

var tile_map: TileMapLayer

var rng = RandomNumberGenerator.new()
var cells: Array[Vector2i] = []

func clear_map() -> void:
	cells = []
	tile_map.clear()
	var size_x =map_size.x + map_padding
	var size_y = map_size.y + map_padding
	for x in range(-size_x, size_x):
		for y in range(-size_y, size_y):
			tile_map.set_cell(Vector2(x, y), 0, EMPTY_ATLAS_TILE)

# returns player spawn position
func generate_map() -> Vector2i:
	_generate_rooms()

	var max_cell: Vector2i = _find_max_cell()
	var min_cell: Vector2i = _find_min_cell()
	var right_middle_cell = Vector2i(max_cell.x, _find_middle_y(max_cell.x))
	var left_middle_cell = Vector2i(min_cell.x, _find_middle_y(min_cell.x))
	
	var level_exit_position = _get_cell_global_position(right_middle_cell)
	game_manager.create_level_exit(level_exit_position)

	var spawn_position = _get_cell_global_position(left_middle_cell)
		
	create_coins()
	create_enemies(spawn_position)

	return spawn_position

# Algorithm is based on https://github.com/munificent/hauberk/blob/db360d9efa714efb6d937c31953ef849c7394a39/lib/src/content/dungeon.dart
func _generate_rooms() -> void:
	var rooms: Array[Rect2i] = []
	
	for iteration in range(room_gen_iterations):
		var size = rng.randi_range(room_min_size, room_max_size)
		var width = size
		var height = size
		
		# make room a rectangular
		if rng.randi_range(0, 1):
			width += rng.randi_range(0, size / 2.0) * 2
		else:
			height += rng.randi_range(0, size / 2.0) * 2

		var x = rng.randi_range(0, map_size.x - width)
		var y = rng.randi_range(0, map_size.y - height)
		
		var new_room: Rect2i = Rect2i(x, y, width, height)
		# leave some space for overlap checks
		var new_room_padded = _get_rect_padded(new_room, 1)

		# check rooms overlap
		var skip: bool = false
		for room in rooms:
			if !new_room_padded.intersects(room):
				# no intersection - skip adding room
				skip = true
				break
		
		if skip:
			continue
		
		rooms.append(new_room)
		
		# append every cell from a rect to tile cells
		for i in range(new_room.position.x, new_room.position.x + new_room.size.x):
			for j in range(new_room.position.y, new_room.position.y + new_room.size.y):
				cells.append(Vector2i(i, j))

	_set_terrain_cells()

func _find_max_cell() -> Vector2i:
	var max_cell: Vector2 = Vector2(-INF, -INF)
	for cell in tile_map.get_used_cells():
		if _is_tile_ground(cell):
			max_cell.x = max(max_cell.x, cell.x)
			max_cell.y = max(max_cell.y, cell.y)
	
	return max_cell

func _find_min_cell() -> Vector2i:
	var min_cell: Vector2 = Vector2(INF, INF)
	for cell in tile_map.get_used_cells():
		if _is_tile_ground(cell):
			min_cell.x = min(min_cell.x, cell.x)
			min_cell.y = min(min_cell.y, cell.y)

	return min_cell

func _find_middle_y(x: int) -> int:
	var max_y: float = -INF
	var min_y: float = INF
	for cell in tile_map.get_used_cells():
		if cell.x == x and _is_tile_ground(cell):
			min_y = min(min_y, cell.y)
			max_y = max(max_y, cell.y)

	return int(floor(min_y + (max_y - min_y) / 2.0))

func _is_tile_ground(tile_pos: Vector2i) -> bool:
	var tile_data = tile_map.get_cell_tile_data(tile_pos)
	if tile_data:
		return tile_data.get_custom_data("ground")
	return false

func _is_tile_empty(tile_pos: Vector2i) -> bool:
	return tile_map.get_cell_source_id(tile_pos) == -1

func _get_rect_padded(rect: Rect2i, padding: int) -> Rect2i:
	var padded_rect = rect
	padded_rect.position.x -= padding
	padded_rect.position.y -= padding
	padded_rect.size.x += padding
	padded_rect.size.y += padding
	return padded_rect

func _set_terrain_cells() -> void:
	tile_map.set_cells_terrain_connect(cells, ROOM_TERRAIN_SET, ROOM_TERRAIN)

func _get_cell_global_position(cell: Vector2i) -> Vector2i:
	return cell * tile_map.tile_set.tile_size + tile_map.tile_set.tile_size / 2

# randomly create coins on ground tiles
func create_coins() -> void:
	var spawned_coins = 0
	
	while spawned_coins < GlobalVariables.coins_per_level:
		for tile_map_cell in tile_map.get_used_cells():
			if spawned_coins >= GlobalVariables.coins_per_level:
				break
			if _is_tile_ground(tile_map_cell):
				if randf() < GlobalVariables.coin_spawn_chance:
					var cell_pos = _get_cell_global_position(tile_map_cell)
					game_manager.create_coin(cell_pos)
					spawned_coins += 1

# randomly create enemies on ground tiles, distance away from the player
func create_enemies(spawn_position: Vector2i) -> void:
	var spawned_enemies = 0
	
	while spawned_enemies < GlobalVariables.enemies_per_level:
		for tile_map_cell in tile_map.get_used_cells():
			if spawned_enemies >= GlobalVariables.enemies_per_level:
				break
			if _get_cell_global_position(tile_map_cell).distance_to(spawn_position) <= GlobalVariables.enemy_spawn_distance_from_player:
				continue
			if _is_tile_ground(tile_map_cell):
				if randf() < GlobalVariables.coin_spawn_chance:
					var cell_pos = _get_cell_global_position(tile_map_cell)
					game_manager.create_enemy(cell_pos)
					spawned_enemies += 1
