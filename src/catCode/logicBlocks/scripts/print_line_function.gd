extends function_block

func execute(text := [""]):
	parent.print_line(convert_to_string(text[0]))
