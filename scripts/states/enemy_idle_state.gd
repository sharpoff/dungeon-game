extends State
class_name EnemyIdleState

@export var enemy: Enemy

var player: Player

var move_direciton: Vector2
var wander_time: float

func randomize_wander():
	move_direciton = Vector2(randi_range(-1, 1), randi_range(-1, 1))
	wander_time = randf_range(1, 3)

func enter() -> void:
	player = get_tree().get_first_node_in_group("player")
	randomize_wander()

func exit() -> void:
	pass

func update(delta: float) -> void:
	if wander_time > 0:
		wander_time -= delta
	else:
		enemy.velocity = Vector2()
		randomize_wander()

func physics_update(_delta: float) -> void:
	if enemy:
		enemy.velocity = move_direciton * GlobalVariables.enemy_move_speed
	
	if !GlobalVariables.game_ended and player:
		var direction = player.global_position - enemy.global_position
		if direction.length() < GlobalVariables.enemy_follow_distance:
			transitioned.emit(self, "follow")
