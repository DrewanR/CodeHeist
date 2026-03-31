extends OptionButton

var items = []

func get_param_value() -> String:
	return get_item_text(selected)


func set_param_value(_value :String) -> void:
	selected = items.find(_value)


func set_param_label(_value :String) -> void:
	pass


func refresh_items(new_items :Array[String]) -> void:
	clear()
	for this_item in new_items:
		add_item(this_item)
	items = new_items
