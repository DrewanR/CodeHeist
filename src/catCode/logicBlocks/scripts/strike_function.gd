extends function_block

func execute(direction := []):
	if len(direction) == 1 and direction[0] != "": # TODO: Add parameter functionality here!
		parent.parent.strike(convert_to_float(direction[0]))
		#parent.print_line("> Swipe " + direction[0])
	elif not parent.parent == null:
		parent.parent.strike()
		#parent.print_line("> Swipe")
	else:
		parent.print_line("! Parent with swipe not found...")
