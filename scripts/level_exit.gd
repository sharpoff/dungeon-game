extends Area2D
class_name LevelExit

@export var game_manager: GameManager
var load_priority: String = "low"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SoundManager.hatch_open_sound.play()
		game_manager.change_level()

func save() -> Dictionary:
	var save_dict = {
		"filename": scene_file_path,
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
		"load_priority": load_priority,
		"version": 1,
	}
	return save_dict

func load_game(data: Dictionary, new_game_manager: GameManager) -> void:
	if data.is_empty():
		print_debug("failed to load_game() - data is empty.")
		return
	
	game_manager = new_game_manager
	position = Vector2(data["pos_x"], data["pos_y"])
