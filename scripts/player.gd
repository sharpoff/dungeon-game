extends CharacterBody2D

const SPEED = 100.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down").normalized()
	velocity = direction * SPEED
	
	# rotate sprite based on their direction
	if direction.x:
		animated_sprite.flip_h = direction.x < 0
	
	move_and_slide()
