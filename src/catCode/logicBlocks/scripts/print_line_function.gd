extends function_block

func execute(text := ["No text provided"]):
	parent.print_line(convert_to_string(text[0]))
