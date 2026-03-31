extends LineEdit


func get_param_value() -> String:
	return text


func set_param_value(_value :String) -> void:
	text = _value 


func set_param_label(_value :String) -> void:
	placeholder_text = _value
