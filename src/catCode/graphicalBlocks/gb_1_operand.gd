extends graphical_block

## Pulls the values from the nodes into [params]
## Returns an array of the current params
func pull_params(will_emit_signal :bool = false) -> Array:
	params = []
	for this_parameter_node in parameter_nodes:
		params = this_parameter_node.get_value()
	
	if will_emit_signal: parameters_updated.emit(line_number, params)
	return params

## Pushes the values in [params] to the nodes
func push_params(will_emit_signal :bool = false):
	parameter_nodes[0].set_value(params)
	
	refresh.emit()
	if will_emit_signal: parameters_updated.emit(line_number, params)

func refresh_content():
	super.refresh_content()
	if code_editor != null:
		parameter_nodes[0].update_options(code_editor.operand_list)
