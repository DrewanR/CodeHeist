extends auto_controller

func _process(delta: float) -> void:
	jump_logic(delta)

## Jumping and the floaty part of jumps. [br]
##
## Contains the logic for:
##   Impulse jumps,
##   Air hovering
##
## [br] Uses [direction] for ledge kicks
## Uses [delta] to process the floaty part of jumps
func jump_logic(delta: float) -> void:
	if Input.is_action_just_pressed("primary_action") and cat_bot.can_jump(): # JUMP
		cat_bot.jump()
	elif cat_bot.is_air_hovering(): # That thing where holding down the button can adjust the height
		cat_bot.air_hover(delta)
