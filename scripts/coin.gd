extends Area2D
class_name Coin

@export var game_manager: GameManager

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var load_priority: String = "low"

func _ready() -> void:
	animated_sprite.play("idle")
	var rand_frame = randi() % animated_sprite.sprite_frames.get_frame_count("idle")
	animated_sprite.frame = rand_frame

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		game_manager.increase_coins()
		SoundManager.coin_pickup_sound.play()
		queue_free()

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
