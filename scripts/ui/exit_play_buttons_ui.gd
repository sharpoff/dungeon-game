extends HBoxContainer

@export var game_manager: GameManager

func _on_play_pressed() -> void:
	game_manager.start_game()

func _on_exit_pressed() -> void:
	game_manager.exit()
