class_name graphical_block extends HBoxContainer

# Attributes
#============

# Publically available information

var indentifier :String = "block"
var params :Array = []
var indent :int = 0
var line_number :int = 0
var is_valid_line :bool = true

# Signals

#signal block_updated(line_number :int,)
signal parameters_updated(line_number :int, new_params :Array)
signal indent_updated(line_number :int, new_indent :int)
signal refresh

# Backend information

var consituent_block :logic_block
var indent_node :PackedScene = preload("res://src/catCode/graphicalComponents/basic_indent_node.tscn")
var indent_node_instances :Array[Node] = [] 

@onready var indent_node_source = $IndentContainer

# Export properties

## An array of references to the nodes that contain parameter locations. [br]
## Must be set for parameters to work. Put in order of parameters. [br][br]
## WARNING: All nodes MUST contain the method get_value() and set_value(). [br]
##          This has to be implemented by the developer.
@export var parameter_nodes :Array[Control] = []


# Methods
#=========

func _ready() -> void:
	refresh_content()

## Updates line from a logic block
func bind_from_block(block :logic_block, _line_number :int = 0):
	consituent_block = block
	indentifier = block.block_ref
	line_number = _line_number
	refresh_content()

## Updates line from an instruction
func bind_from_instruction(instruction :instruction_line, _line_number :int = 0):
	consituent_block = instruction.primary_block
	indentifier = consituent_block.block_ref
	params = instruction.parameters
	indent = instruction.indent
	line_number = _line_number
	refresh_content()

func refresh_content():
	push_params(true)
	refresh_indent_nodes()
	refresh.emit()

# Validity

## Sets the validity of this node
func set_validity(value :bool):
	is_valid_line = value
	modulate = Color8(255, 255, 255, 255) if is_valid_line else Color8(255, 128, 128, 255)

# Instructions

func get_instruction_line():
	return instruction_line.new(indent, consituent_block, get_params())

# Params

## Sets the parameters to values defined by [params]
func set_params(_params = [], will_emit_signal :bool = true):
	params = _params
	push_params(false)
	if will_emit_signal: parameters_updated.emit(line_number, params)

## Returns the parameters
func get_params():
	pull_params(false)
	return params

## Pushes the values in [params] to the nodes
func push_params(will_emit_signal :bool = false):
	for i in range(0, 0):#len(params)):
		parameter_nodes[i].set_value(params[i])
	
	refresh.emit()
	if will_emit_signal: parameters_updated.emit(line_number, params)

## Pulls the values from the nodes into [params]
## Returns an array of the current params
func pull_params(will_emit_signal :bool = false) -> Array:
	params = []
	for this_parameter_node in parameter_nodes:
		params.append(this_parameter_node.get_value())
	
	if will_emit_signal: parameters_updated.emit(line_number, params)
	return params

# Indent

## Sets the indent to the specified value
func set_indent(_indent :int, will_emit_signal :bool = true):
	indent =  _indent
	refresh_indent_nodes()
	if will_emit_signal: indent_updated.emit(line_number, indent)

## Returns the current indent
func get_indent():
	return indent

## Increases the indent by amount
func increase_indent(amount :int = 1, will_emit_signal :bool = true):
	indent += amount
	refresh_indent_nodes()
	if will_emit_signal: indent_updated.emit(line_number, indent)

## Decreased the indent by amount
func decrease_indent(amount :int = 1, will_emit_signal :bool = true):
	if indent > 0: increase_indent(amount * -1, will_emit_signal)

## Destroyes all the indent nodes than instantiates the appropirate number
func refresh_indent_nodes():
	destroy_indent_nodes()
	indent_node_source.visible = (indent > 0)
	for i in range(0, indent):
		indent_node_instances.append(indent_node.instantiate())
		indent_node_source.add_child(indent_node_instances[-1])

## Removes all the indent nodes
func destroy_indent_nodes():
	while len(indent_node_instances) > 0:
		var this_instance = indent_node_instances.pop_front()
		this_instance.queue_free()

func _to_string() -> String:
	return "Graphical node: " + str(get_instruction_line())
