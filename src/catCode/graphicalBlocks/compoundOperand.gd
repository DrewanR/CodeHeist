extends operand

var operand_options := []

func refresh_content(_identifier :String = ""):
	operand_options = container.options
	
	for param_node in parameter_nodes:
		param_node.update_options(operand_options)
	
	super.refresh_content(_identifier)
