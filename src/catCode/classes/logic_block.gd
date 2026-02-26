@abstract class_name logic_block extends Node
# Note: Node here is used to allow drag and dropping in the godot editor
#		this is not actually required for these classes to function.

## Signal emitted when/if errors occur.
## Carries error message specified by [param message].
signal error_occurred(message :String)

@export var block_name     :String ## The name of the current block
@export var block_category :String ## The type of block

@export var ui_block :PackedScene ## The graphical_block equivalent of this logical block

var block_type :String

## Declares an error has occurred [br]
## Emits [signal error_occurred]
func send_error(text := "An error occurred"):
	error_occurred.emit(text)

## Returns true if type of this block matches [param _type]
func is_type(_type :String) -> bool:
	return _type == block_type

## Returns the number of identifiers for this block
@abstract
func get_reference_count() -> int

# Returns the primary identify for this  block
@abstract
func get_primary_reference() -> String

# Utilities
#===========

## Converts to string. [br]
## Note: If a boolean operator is put into this method, it will be evaluated.
func convert_to_string(arg) -> String:
	return str(arg)
