extends TileMapLayer

var load_priority: String = "low"

func save() -> Dictionary:
	var save_dict = {
		"filename": scene_file_path, # used to instanciate
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"load_priority": load_priority,
		"version": 1,
		"cells": []
	}
	
	for cell in get_used_cells():
		var source_id = get_cell_source_id(cell)
		var atlas_coords = get_cell_atlas_coords(cell)
		
		save_dict["cells"].append({
			"x": cell.x,
			"y": cell.y,
			"source_id": source_id,
			"atlas_coords_x": atlas_coords.x,
			"atlas_coords_y": atlas_coords.y,
		})
	
	return save_dict

func load_game(data: Dictionary, _game_manager: GameManager) -> void:
	if data.is_empty():
		print_debug("failed to load_game() - data is empty.")
		return
	var cells = data.get("cells")
	for cell in cells:
		set_cell(Vector2i(cell["x"], cell["y"]), cell["source_id"], Vector2i(cell["atlas_coords_x"], cell["atlas_coords_y"]))
	
	position = Vector2(data["pos_x"], data["pos_y"])
