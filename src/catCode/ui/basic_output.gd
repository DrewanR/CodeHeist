extends TextEdit

func print_line(message) -> void:
	if text != "":
		text += "\n"
	text += message
	scroll_vertical = 99999
