extends Sprite2D

func _process(delta: float) -> void:
	rotation += delta


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/test/test_level_00.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/test/test_level_01.tscn")
