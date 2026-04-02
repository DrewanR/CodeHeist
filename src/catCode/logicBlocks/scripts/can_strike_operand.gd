extends boolean_operator

func evaluate(_args :Array = []) -> bool:
	if not parent.parent == null:
		return parent.parent.can_strike()
	else:
		parent.print_line("! Parent with can_strike() not found...")
		return false
