extends boolean_operator

func evaluate(_args :Array = []) -> bool:
	var operand_1 = _args[0]
	
	return (
		not
		operand_1[0].evaluate(operand_1[1])
	)
