class_name instruction_line

var indent :int
var primary_block :logic_block
var parameters :Array
var executable :bool

func _init(_indent :int, _primary_block :logic_block, _parameters :Array = []) -> void:
	indent = _indent
	primary_block = _primary_block
	parameters = _parameters
	
	match primary_block.block_type:
		"function_block":
			executable = true
		_:
			executable = false

func is_executable():
	return executable
