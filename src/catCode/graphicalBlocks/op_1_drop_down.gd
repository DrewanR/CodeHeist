extends operand

## Pushes the values in [params] to the nodes
func push_params(will_emit_signal :bool = false):
	parameter_nodes[0].refresh_items(container.constituent_block.get_available_options())
	if len(params) > 0: parameter_nodes[0].set_param_value(params[0])
	
	refresh.emit()
	if will_emit_signal: parameters_updated.emit(params)
