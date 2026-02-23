@abstract class_name boolean_operator extends logic_block

@export var block_ref :String ## Textual reference to block (identifier)

@export var params :Array[String] = [] ## Parameters, leave blank for non params

@export var parent :Node ## The node executing this function, leave blank for direct parent

func _ready() -> void:
	if parent == null:
		parent = get_parent()
	block_type = "booleanOperator"

	name = "logicBlock_booleanOperator_" + block_name.to_camel_case()

## Evaluates the conditional
func evaluate(_args :Array = []) -> bool:
	send_error(block_ref + " has not been implemented.")
	return false

## Returns true if [param reference] refers to this block
func is_reference(reference :String) -> bool:
	return reference == block_ref

## Returns the number off parameters 
func get_parameter_count() -> int:
	return len(params)

## Returns true is this function has any parameters
func has_parameters() -> bool:
	return len(params) > 0

## Returns the number of identifiers for this block
func get_reference_count() -> int:
	return 1

# Returns the primary identify for this  block
func get_primary_reference() -> String:
	return block_ref
