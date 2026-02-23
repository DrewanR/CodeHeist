@abstract class_name conditional_block extends logic_block

@export var block_ref :String ## Textual reference to block (identifier)

@export var parent :Node ## The node executing this function, leave blank for direct parent

func _ready() -> void:
	if parent == null:
		parent = get_parent()
	block_type = "conditional_block"

	name = "logicBlock_conditional_" + block_name

## Evaluates the conditional
func evaluate():
	send_error(block_ref + " has not been implemented.")
	return true

## Returns true if [param reference] refers to this block
func is_reference(reference :String) -> bool:
	return reference == block_ref

## Returns the number of identifiers for this block
func get_reference_count() -> int:
	return 1

# Returns the primary identify for this  block
func get_primary_reference() -> String:
	return block_ref
