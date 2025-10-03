extends State
class_name EnemyFollowState

@export var enemy: Enemy
@export var cooldown_timer: Timer

var player: Player

func enter() -> void:
	player = get_tree().get_first_node_in_group("player")

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	if GlobalVariables.game_ended:
		enemy.velocity = Vector2()
		transitioned.emit(self, "idle")
		return
	
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 20:
		enemy.velocity = direction.normalized() * GlobalVariables.enemy_move_speed
	elif cooldown_timer.is_stopped():
		enemy.velocity = Vector2()
		transitioned.emit(self, "attack")
		cooldown_timer.start()
	
	if direction.length() > GlobalVariables.enemy_stop_follow_distance:
		transitioned.emit(self, "idle")
