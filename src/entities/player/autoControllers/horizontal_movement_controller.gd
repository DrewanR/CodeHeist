extends auto_controller

## If [true] will invert controls. This will have unexpected consequences.
## Note: this exists purely for fun :3
@export var invert_movement := false 

func _process(delta: float) -> void:
	if not invert_movement:
		cat_bot.run(delta, cat_bot.get_direction_x(), 1)
	else:
		cat_bot.run(delta, cat_bot.get_direction_x(), -1)
