extends iteration_block

@export var params :Array = []

## Returns true if loop should continue
func evaluate(args := [null]):
	if len(args) == 0 or args[0] == null:
		print("    No args")
		return false
	else:
		print("    Rep: " + str(args[1].rep))
		if (args[1].rep <= int(args[0])):
			print("    Continuing loop")
			return true
		else:
			print("    Ending loop")
			return false
