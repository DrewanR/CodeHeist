extends boolean_operator

@export var permitted_buttons :Dictionary[String,bool] = {
	"primary_action":   false,
	"secondary_action": false,
	"z":     true,
	"x":     true,
	"up":    true,
	"down":  true,
	"left":  true,
	"right": true
}

func evaluate(_args :Array = []) -> bool:
	# Checks that desired button for testing is valid
	if (
		len(_args) == 0 or
		not permitted_buttons.has(_args[0]) or 
		not permitted_buttons[_args[0]]
	):
		send_error("Invalid arguments, this error should not occur using graphical coding")
		return false
	# Returning the result
	else:
		if _args[0].to_upper() == "Z":
			return Input.is_action_just_pressed("primary_action")
		elif _args[0].to_upper() == "X":
			return Input.is_action_just_pressed("secondary_action")
		else:
			return Input.is_action_just_pressed(_args[0])

## Returns the button available for the player to use
func get_available_options() -> Array[String]:
	var valid_buttons :Array[String] = []
	for this_button in permitted_buttons.keys():
		if permitted_buttons[this_button]:
			valid_buttons.append(this_button)
	return valid_buttons
