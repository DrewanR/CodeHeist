extends auto_controller

## If [true] this controller will only send strike calls if catBot can strike [br]
## Note: this controller should be used in a "safe" configuration where possible
@export var strike_only_when_possible := true 

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("secondary_action") and (cat_bot.can_strike() or !strike_only_when_possible):
		cat_bot.strike()
