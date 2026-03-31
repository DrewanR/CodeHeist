extends SpinBox


func get_param_value() -> String:
	return str(value/100)


func set_param_value(_value :String) -> void:
	value = int(_value)*100


func set_param_label(_value :String) -> void:
	prefix = _value
