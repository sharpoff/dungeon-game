# Algorithm is based on https://journal.stuffwithstuff.com/2014/12/21/rooms-and-mazes/

extends Node
class_name MapGenerator

const ROOM_TERRAIN_SET: int = 0
const ROOM_TERRAIN: int = 0

@onready var tile_map: TileMapLayer = $TileMap
@onready var tile_size: Vector2i = tile_map.tile_set.tile_size

@export var map_size: Vector2i = Vector2i(20, 20)
@export var room_min_size: int = 3
@export var room_max_size: int = 5
@export var room_gen_iterations: int = 10 # how many times to try to generate a room

func _ready() -> void:
	generate_map()

func generate_map() -> void:
	var rng = RandomNumberGenerator.new()
	var rooms: Array[Rect2i] = []
	var cells: Array[Vector2i] = []
	
	for iter in range(room_gen_iterations):
		var size = rng.randi_range(room_min_size, room_min_size + room_max_size)
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
		
		# check rooms overlap
		var overlaps: bool = false
		for room in rooms:
			if new_room.encloses(room):
				overlaps = true
				break
		
		if overlaps:
			continue
		
		rooms.append(new_room)
		
		# append every cell from a rect to tile cells
		for i in range(new_room.position.x, new_room.position.x + new_room.size.x):
			for j in range(new_room.position.y, new_room.position.y + new_room.size.y):
				cells.append(Vector2i(i, j))

	tile_map.set_cells_terrain_connect(cells, ROOM_TERRAIN_SET, ROOM_TERRAIN)
