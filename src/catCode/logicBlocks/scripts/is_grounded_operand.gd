extends boolean_operator

## WARNING: uses coyote grounded
func evaluate(_args :Array = []) -> bool:
	if not parent.parent == null:
		return parent.parent.is_coyote_grounded()
	else:
		parent.print_line("! Parent with is_grounded() not found...")
		return false
