extends CharacterBody2D
class_name Player

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var invincible_timer: Timer = $InvincibleTimer

var handling_input: bool = true: set = set_input
var health: float
var is_invincible: bool = false

var knockback = Vector2.ZERO

signal health_changed(health: int)

func _ready() -> void:
	dash_timer.wait_time = GlobalVariables.player_dash_time
	dash_cooldown_timer.wait_time = GlobalVariables.player_dash_cooldown
	invincible_timer.wait_time = GlobalVariables.player_invincible_time
	
	health = GlobalVariables.player_max_health
	health_changed.emit(health)
	
	animated_sprite.play("idle")
	var rand_frame = randi() % animated_sprite.sprite_frames.get_frame_count("idle")
	animated_sprite.frame = rand_frame

func _process(_delta: float) -> void:
	if is_invincible:
		animated_sprite.modulate = Color(2, 2, 2, 1)
	else:
		animated_sprite.modulate = Color(1, 1, 1, 1)
	
	if Input.is_action_just_pressed("dash") and dash_timer.is_stopped() and dash_cooldown_timer.is_stopped():
		dash_timer.start()
		SoundManager.dash_sound.play()
		is_invincible = true

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if !handling_input:
		return

func _physics_process(_delta: float) -> void:
	if !handling_input:
		return

	var move_speed = GlobalVariables.player_move_speed
	
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * (move_speed * 2.5 if !dash_timer.is_stopped() else move_speed)
	
	# apply knockback
	if knockback != Vector2.ZERO:
		velocity += knockback
		knockback = knockback.lerp(Vector2.ZERO, 0.1)
	
	# rotate sprite based on their direction
	if direction.x:
		animated_sprite.flip_h = direction.x < 0
	
	move_and_slide()

func set_input(value: bool) -> void:
	handling_input = value

func set_visiblity(value: bool) -> void:
	animated_sprite.visible = value

func damage(attack: Attack) -> void:
	if is_invincible:
		return
	
	health -= attack.damage
	var knockback_dir = attack.origin_position.direction_to(global_position)
	knockback = knockback_dir * attack.knockback
	
	invincible_timer.start()
	is_invincible = true
	
	SoundManager.player_damage_sound.play()
	health_changed.emit(health)

func _on_dash_timer_timeout() -> void:
	dash_cooldown_timer.start()
	is_invincible = false

func _on_invincible_timer_timeout() -> void:
	is_invincible = false
