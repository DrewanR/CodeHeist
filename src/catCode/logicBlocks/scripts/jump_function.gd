extends function_block

func execute(strength := []):
	if len(strength) == 1 and strength[0] != "": # TODO: Add parameter functionality here!
		parent.parent.jump(convert_to_float(strength[0]))
		parent.print_line("> Jump " + strength[0])
	elif not parent.parent == null:
		parent.parent.jump()
		parent.print_line("> Jump")
	else:
		parent.print_line("! Parent with jump not found...")
