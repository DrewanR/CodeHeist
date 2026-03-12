extends boolean_operator

@export var value :bool = false

func _ready() -> void:
	if parent == null:
		parent = get_parent()
	block_type = "booleanOperator"
	
	block_ref = str(value)
	
	name = "logicBlock_booleanOperator_" + str(value)

func evaluate(_args :Array = []) -> bool:
	return value
