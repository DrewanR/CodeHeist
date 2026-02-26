@abstract class_name iteration_block extends logic_block

@export var block_ref :String ## Textual reference to block (identifier)

@export var uses_boolean_operator :bool = false ## If true, will use a boolean operator

@export var await_new_frame :bool = false ## Used by the interpreter, if true, each iteration will wait for a new frame

@export var parent :Node ## The node executing this function, leave blank for direct parent

func _ready() -> void:
	if parent == null:
		parent = get_parent()
	block_type = "iterative_block"

	name = "logicBlock_iterative_" + block_name.to_camel_case()

## Evaluates the conditional
func evaluate():
	send_error(block_ref + " has not been implemented.")
	return false

## Returns true if [param reference] refers to this block
func is_reference(reference :String) -> bool:
	return reference == block_ref

## Returns true if an operator is used
func is_using_boolean_operator() -> bool:
	return uses_boolean_operator

func should_wait_from_next_frame() -> bool:
	return await_new_frame

## Returns the number of identifiers for this block
func get_reference_count() -> int:
	return 1

# Returns the primary identify for this  block
func get_primary_reference() -> String:
	return block_ref
