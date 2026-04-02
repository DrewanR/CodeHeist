extends boolean_operator

func evaluate(_args :Array = []) -> bool:
	var operand_1 = _args[0]
	var operand_2 = _args[1]
	
	return (
		operand_1[0].evaluate(operand_1[1])
		or
		operand_2[0].evaluate(operand_2[1])
	)
