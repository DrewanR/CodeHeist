extends auto_controller

## If [true] this controller will only send strike calls if catBot can strike [br]
## Note: this controller should be used in a "safe" configuration where possible
@export var strike_only_when_possible := true 

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
	if jump_when_grounded_only:
		if Input.is_action_just_pressed("primary_action") and cat_bot.can_jump(): # JUMP
			cat_bot.jump()
		elif cat_bot.is_air_hovering() and handle_jump_adjustment: # That thing where holding down the button can adjust the height
			cat_bot.air_hover(delta)
	else:
		if Input.is_action_just_pressed("primary_action"): # JUMP
			cat_bot.jump()
		elif cat_bot.is_air_hovering() and handle_jump_adjustment: # That thing where holding down the button can adjust the height
			cat_bot.air_hover(delta)
