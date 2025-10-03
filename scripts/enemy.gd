extends CharacterBody2D
class_name Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var animation_direction: String = "right"
var load_priority: String = "low"

func _process(_delta: float) -> void:
	$DebugStateLabel.text = $StateMachine.current_state.name
	
	if !animation_player.is_playing() and !velocity:
		animation_player.play("idle_" + animation_direction)
	elif velocity:
		animation_player.play("move_" + animation_direction)

func _physics_process(_delta: float) -> void:
	if velocity.x > 0:
		animation_direction = "right"
	elif velocity.x < 0:
		animation_direction = "left"
	
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("damage"):
		var attack: Attack = Attack.new()
		attack.damage = GlobalVariables.enemy_damage
		attack.knockback = GlobalVariables.enemy_attack_knockback
		attack.origin_position = global_position
		body.damage(attack)

func play_attack_sound() -> void:
	SoundManager.sword_sound.play()

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

func load_game(data: Dictionary, _game_manager: GameManager) -> void:
	if data.is_empty():
		print_debug("failed to load_game() - data is empty.")
		return
	
	position = Vector2(data["pos_x"], data["pos_y"])
