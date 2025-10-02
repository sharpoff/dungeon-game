extends Area2D
class_name LevelExit

@export var game_manager: GameManager

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SoundManager.hatch_open_sound.play()
		game_manager.change_level()
