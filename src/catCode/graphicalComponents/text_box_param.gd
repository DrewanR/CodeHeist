extends LineEdit


func get_value() -> String:
	return text


func set_value(value :String) -> void:
	text = value 


func set_param_label(value :String) -> void:
	placeholder_text = value
