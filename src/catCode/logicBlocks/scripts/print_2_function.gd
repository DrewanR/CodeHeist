extends function_block

func execute(text := ["",""]):
	parent.print_line(str(text[0]) + " " + str(text[1]))
