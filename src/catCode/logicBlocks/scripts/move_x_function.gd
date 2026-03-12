extends function_block

func execute(args := []):
	if len(params) == 1:
		parent.parent.run(get_process_delta_time(), 1, float(args[0]))
	elif len(params) == 2:
		if args[0].to_upper()[0] == "L":
			parent.parent.run(get_process_delta_time(), -1, float(args[1]))
		elif args[0].to_upper()[0] == "R":
			parent.parent.run(get_process_delta_time(), 1, float(args[1]))
	else:
		parent.print_line("! Something went wrong...")
