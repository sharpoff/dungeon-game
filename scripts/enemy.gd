extends CharacterBody2D
class_name Enemy

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var debug_state_label: Label = $DebugStateLabel

var game_manager: GameManager
var animation_direction: String = "right"

func _ready() -> void:
	$StateMachine/Idle.game_manager = game_manager
	$StateMachine/Follow.game_manager = game_manager

func _process(_delta: float) -> void:
	debug_state_label.text = $StateMachine.current_state.name
	
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
