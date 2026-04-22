extends Node

@export var slides :Array[PackedScene]

var current_slide = 0


func get_current_slide():
	return current_slide


func get_slide_count():
	return len(slides)


func swtich_to_next_slide():
	if current_slide + 1 < get_slide_count():
		current_slide += 1
		get_tree().change_scene_to_packed(slides[current_slide])


func swtich_to_prev_slide():
	if current_slide > 0:
		current_slide -= 1
		get_tree().change_scene_to_packed(slides[current_slide])
