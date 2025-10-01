extends Area2D
class_name Coin

@export var game_manager: GameManager

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		game_manager.increase_coins()
		queue_free()
