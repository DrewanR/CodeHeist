class_name operand extends PanelContainer

# Attributes
#============

# Publicly available information

var indentifier :String = "Operand" #TODO: Fix spelling
var params :Array = []

# Signals

signal parameters_updated(new_params :Array)
signal refresh

# Export properties

## An array of references to the nodes that contain parameter locations. [br]
## Must be set for parameters to work. Put in order of parameters. [br][br]
## WARNING: All nodes MUST contain the method get_value() and set_value(). [br]
##          This has to be implemented by the developer.
@export var parameter_nodes :Array[Control] = []


# Methods
#=========

func refresh_content(_identifier :String = ""):
	if _identifier != "": indentifier = _identifier
	push_params(true)
	refresh.emit()

func pass_args(args :Array):
	set_params(args)
	refresh_content()


# Params

## Sets the parameters to values defined by [params]
func set_params(_params = [], will_emit_signal :bool = true):
	params = _params
	push_params(false)
	if will_emit_signal: parameters_updated.emit(params)

## Returns the parameters
func get_params():
	pull_params(false)
	return params

## Pushes the values in [params] to the nodes
func push_params(will_emit_signal :bool = false):
	for i in range(0, len(params)):
		print("      " + str(parameter_nodes[i]))
		parameter_nodes[i].set_value(params[i])
	
	refresh.emit()
	if will_emit_signal: parameters_updated.emit(params)

## Pulls the values from the nodes into [params]
## Returns an array of the current params
func pull_params(will_emit_signal :bool = false) -> Array:
	params = []
	for this_parameter_node in parameter_nodes:
		params.append(this_parameter_node.get_value())
	
	if will_emit_signal: parameters_updated.emit(params)
	return params
