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

## Returns a rich-text string including the name of the block
## and a description of it.
func get_formatted_block_description() -> String:
	var action = "If put into an if statement, the indented code will always run." if value else "If put into an if statement, the indented code will never run."
	return "[b][i]%s[/i][/b]\n   Represents a boolean value of %s.\n   %s" % [block_name, block_name, action]
