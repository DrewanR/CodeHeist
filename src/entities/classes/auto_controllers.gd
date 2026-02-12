class_name auto_controller extends Node

@onready var cat_bot = get_catBot()

func get_catBot() -> player_cat:
	return get_parent()
