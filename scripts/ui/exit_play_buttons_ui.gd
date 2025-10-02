extends HBoxContainer

@export var game_manager: GameManager

func _on_play_pressed() -> void:
	game_manager.start_game()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu_ui.tscn")
