extends PanelContainer

enum STATES { NO_OPERAND, HAS_OPERAND }
var current_state = STATES.NO_OPERAND

## The block currently represented by this operand container
var constituent_block :logic_block = null

## Node spawned as a child of this to represent the operand
var child_node :operand

## Used whenever a result is requested by editor but one is not present
var false_fallback = preload("res://src/catCode/logicBlocks/nodes/boolean_value.tscn")

## Boolean operators available
var options :Array[boolean_operator] = []

## Selector node, visible only when this block represents null
@onready var selector :MenuButton = $MarginContainer/HBoxContainer/Selecter
## Node that the child node shall be a child of
@onready var container := $MarginContainer/HBoxContainer

func _ready() -> void:
	#false_fallback = false_fallback.instantiate()
	#add_child(false_fallback)
	#update_options([false_fallback, false_fallback])
	selector.get_popup().id_pressed.connect(upon_item_selected)


func update_options(_options :Array[boolean_operator]):
	print("Updating options:")
	options = _options
	for this_option in _options:
		print("  " + str(this_option))
		selector.get_popup().add_item(this_option.block_name.capitalize())


func set_value(value = null):
	if value in [null, []]:
		constituent_block = null
		current_state = STATES.NO_OPERAND
		refresh()
	else:
		constituent_block = value[0]
		refresh()
		child_node.pass_args(value)
		current_state = STATES.HAS_OPERAND


func set_index(index :int) -> void:
	constituent_block = options[index]
	current_state = STATES.HAS_OPERAND
	refresh()


func get_value():
	if current_state == STATES.NO_OPERAND:
		return [false_fallback.instantiate()]
	else:
		var result = [constituent_block]
		result.append_array(child_node.get_params())
		return result


func refresh():
	print("Refreshing:")
	print("  block  = " + str(constituent_block))
	if current_state == STATES.NO_OPERAND:
		selector.visible = true
		child_node.queue_free()
	else:
		selector.visible = false
		if child_node != null: child_node.queue_free()
		print("  constituent block = " + str(constituent_block))
		print("  ui block = " + str(constituent_block.ui_block))
		child_node = constituent_block.ui_block.instantiate()
		container.add_child(child_node)
		child_node.refresh_content(constituent_block.block_name)


func upon_operand_deletion() -> void:
	set_value(null)


func upon_item_selected(id :int) -> void:
	set_index(id)
