extends State
class_name AttackState

@export var enemy: Enemy

func enter() -> void:
	enemy.animation_player.play("attack_" + enemy.animation_direction)
	enemy.velocity = Vector2()

func update(_delta: float) -> void:
	if enemy.animation_player.current_animation != "attack_" + enemy.animation_direction or !enemy.animation_player.is_playing():
		transitioned.emit(self, "idle")
