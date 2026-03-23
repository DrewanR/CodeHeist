class_name instruction_line

var indent :int
var primary_block :logic_block
var parameters :Array
var executable_function :bool = false
var iterative_element :bool = false
var selective_element :bool = false

func _init(_indent :int, _primary_block :logic_block, _parameters :Array = []) -> void:
	indent = _indent
	primary_block = _primary_block
	parameters = _parameters
	
	match primary_block.block_type:
		"function_block":
			executable_function = true
		"conditional_block":
			selective_element = true
		"iterative_block":
			iterative_element = true


func is_executable_function():
	return executable_function

func is_iterative_element():
	return iterative_element

func is_selective_element():
	return selective_element

func valid_parameters():
	return (primary_block.get_parameter_count() == len(parameters))

func uses_parameters():
	return primary_block.has_parameters()

func _to_string() -> String:
	return str(indent) + ": " + str(primary_block.block_name) + "(" + str(parameters) + ")"

func get_next_indent() -> int:
	if iterative_element or selective_element:
		return indent + 1
	else:
		return indent
