extends auto_controller

## If [true] this controller will only send jump calls if catBot can jump [br]
## Note: this controller should be used in a "safe" configuration where possible
@export var jump_when_grounded_only := true 

## If [true] this controller will handle jump adjustmust. [br]
## Warning: this controller only updates cat_bot.using_air_hover in _ready()
@export var handle_jump_adjustment := true

func _ready() -> void:
	cat_bot.using_air_hover = handle_jump_adjustment
	print("Autocontroller set cat_bot.using_air_hover to " + str(cat_bot.using_air_hover))

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
