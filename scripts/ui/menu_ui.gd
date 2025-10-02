extends Control

func _ready() -> void:
	$Main.show()
	$Controls.hide()

func _on_play_pressed() -> void:
	$Main.hide()
	$Controls.show()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _process(_delta: float) -> void:
	if $Controls.visible and Input.is_anything_pressed():
		get_tree().change_scene_to_file("res://scenes/world.tscn")
