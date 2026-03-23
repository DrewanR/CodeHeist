extends conditional_block

var false_fallback := preload("res://src/catCode/logicBlocks/nodes/boolean_value.tscn")

func evaluate(args := [null]):
	var operator = null
	if len(args) == 0:
		print("    No args: 0")
		operator = false_fallback.instantiate()
	elif args[0] == null:
		print("    No args: null")
		operator = false_fallback.instantiate()
	else:
		print("    Has args")
		operator = args[0]
	
	if uses_boolean_operator and len(args) > 1:
		return operator.evaluate(args[1])
	elif uses_boolean_operator:
		return operator.evaluate()
	else:
		return false
