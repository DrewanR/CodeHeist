extends SpinBox


func get_param_value() -> String:
	return str(value)


func set_param_value(_value :String) -> void:
	value = int(_value)


func set_param_label(_value :String) -> void:
	prefix = _value
