extends conditional_block

var false_fallback := preload("res://src/catCode/logicBlocks/nodes/boolean_value.tscn")

func evaluate(args := [null]):
	var operator = null
	if len(args) == 0 or args[0] == null:
		print("    No args")
		operator = false_fallback.instantiate()
	else:
		print("    Has args")
		operator = args[0]
	print(operator)
	if uses_boolean_operator:
		return operator.evaluate()
	else:
		return false
