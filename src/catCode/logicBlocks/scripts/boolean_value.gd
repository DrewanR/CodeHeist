extends boolean_operator

@export var value :bool = false

func _ready() -> void:
	if parent == null:
		parent = get_parent()
	block_type = "boolean_operator"
	
	block_ref  = str(value)
	block_name = str(value)
	
	name = "logicBlock_booleanOperator_" + str(value)

func _init() -> void:
	_ready()

func evaluate(_args :Array = []) -> bool:
	return value
