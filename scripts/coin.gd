extends Area2D
class_name Coin

@export var game_manager: GameManager
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("idle")
	var rand_frame = randi() % animated_sprite.sprite_frames.get_frame_count("idle")
	animated_sprite.frame = rand_frame

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		game_manager.increase_coins()
		SoundManager.coin_pickup_sound.play()
		queue_free()
