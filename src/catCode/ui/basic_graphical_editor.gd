extends Container

## Signal emitted upon code compilation.
signal code_recompiled(new_compiled_code :Array[instruction_line])
## Signal emitted upon code update.
#signal code_updated

@export_category("Relationships")

## You know it, you hate it, the usual hack
@export var parent :Node

## Interal export properties, do not edit on instances unless strucutre has been modified.
@export_subgroup("Internal")

## List of nodes that will be hidden or show when the minimise button is pressed
@export var collapsable_nodes :Array[Control]

## List containing logicBlocks. [br]
## These are the backend instructions containing within [res://src/catCode/logicBlocks/]
##    that inherit the logicalBlock class. [br]
## These are taken from the children of this class. [br][br]
## [br]View [docs/catCode.md] for more information.
var instruction_list :Array[logic_block] = []
## Dictionary containing the same information.
var instruction_dict :Dictionary[String, logic_block] = {}
## List containing only operands
var operand_list :Array[boolean_operator] = []
## List containing exclusively non-operands
var function_list :Array[logic_block] = []

## The draft, local version of the code.
## This may include outdated parameters.
var draft_code :Array[instruction_line]

## The most recently successfully compiled code
var compiled_code :Array[instruction_line]

## References to all of the graphical_nodes
var instruction_nodes :Array[graphical_block]

## The name of the process, i.e. on_z_press, process etc.
var process_name :String = ""

## The current visibility of the window: if [true] the code is visbile, else it is hidden.
var is_collapsed :bool = false

## Node that all of the graphical_blocks will be a child of
@onready var code_container := $MarginContainer/VBoxContainer/CodeContainer

## Button for manually compiling the code
@onready var code_compile_button := $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/SaveButton

## Footer add block button
@onready var block_menu_drop_down := $MarginContainer/PanelContainer/MarginContainer/HBoxContainer2/BlockMenu

## Inline add line button
@onready var inline_block_menu := $MarginContainer/VBoxContainer/PanelContainer/InLineAddButton

## Function header label
@onready var process_label := $MarginContainer/VBoxContainer/FunctionLabel/MarginContainer/HBoxContainer/Label

## Function header desctiption
@onready var process_description_button := $MarginContainer/VBoxContainer/FunctionLabel/MarginContainer/HBoxContainer/Button

## Collapse code button
@onready var collapse_code_button := $MarginContainer/VBoxContainer/HeaderBar/MarginContainer/HBoxContainer/CollapseButton

## Rectangle covering entire screen
@onready var screen_dimmer := $ScreenDimmer

## Called when node enters tree, [br]
## Conects signals, updates process name and clears chache.
func _ready() -> void:
	update_process_name()
	parent.instructions_updated.connect(update_instructions)
	inline_block_menu.get_popup().id_pressed.connect(_opon_item_selected)
	clear_cache()


## Updates draft_code to replect what is currently in the nodes
func compile() -> Array[instruction_line]:
	compiled_code = []
	pull_code()
	
	for line in draft_code:
		compiled_code.append(line)
	
	code_recompiled.emit(compiled_code)
	return compiled_code


## Sets and pushes code from [param new_code] into [draft_code]
func set_code(new_code :Array[instruction_line], will_emit_signal :bool = false):
	draft_code = new_code
	push_code()
	
	if will_emit_signal: code_recompiled.emit(draft_code)


## Pushes code from [draft code] into the nodes. [br]
## WARNING: Does NOT update parameters.
func push_code():
	clear_nodes()
	print("> Pushing code...")
	for i in range(0, len(draft_code)):
		print("- " + str(i) + " " + str(draft_code[i]))
		var this_logic_block :logic_block = draft_code[i].primary_block
		var this_graphical_block :graphical_block = this_logic_block.ui_block.instantiate()
		this_graphical_block.code_editor = self
		instruction_nodes.append(this_graphical_block)
		code_container.add_child(this_graphical_block)
		this_graphical_block.bind_from_instruction(draft_code[i], i)


## Pulls code information, including paramters, compiling them to [draft_code].
func pull_code():
	clear_draft_code()
	print("> Pulling code...")
	for i in range(0, len(instruction_nodes)):
		print("- " + str(i) + " " + str(instruction_nodes[i]))
		draft_code.append(instruction_nodes[i].get_instruction_line())


## Clears all of the graphical nodes (ui)
func clear_nodes():
	print("> Clearing nodes")
	while len(instruction_nodes) > 0:
		var line :Node = instruction_nodes.pop_back()
		line.queue_free()


## Clears all of the draft_code
func clear_draft_code():
	draft_code = []


## Clears both the draft code and the ui nodes
func clear_all(will_emit_signal :bool = false):
	clear_nodes()
	clear_draft_code()
	if will_emit_signal: code_recompiled.emit([])


## Updates both the instruction lists, instruction dictionary, and refreshes the
## menus to reflect changes. Finally, clear both the compiled code and the draft
## code if [param clear] is true. [br]
##
## WARNING: Things may break if blocks are removed and clear is false.
func update_instructions(new_list, new_dict, clear := true):
	update_instruction_lists(new_list)
	update_instruction_dict(new_dict)
	refresh_command_dropdown()
	if clear: clear_all()


## Updates the instruction dictionary to reflect the the value specified by
## [param _instruction_dict]. This is assumed to be in the same format specified
## by the class [code_manager] in [cat_code_manager.gd]
func update_instruction_dict(_instruction_dict):
	instruction_dict = _instruction_dict


## Updates [function_list] and [operator_list] to reflect the values specified
## by [param _instruction_list]. Assumes that the list is full of references to
## instances of the [logic_block] class.
func update_instruction_lists(_instruction_list :Array):
	instruction_list = _instruction_list
	print("-   Updating sublists")	#while len(_instruction_list) > 0:
	#	var block = _instruction_list.pop_front()
	#	if block.block_type == "boolean_operator":
	#		print("-     Adding " + str(block) + " to operator list")
	#		operand_list.append(block)
	#	else:
	#		print("-     Adding " + str(block) + " to function list")
	#		function_list.append(block)
	for block :logic_block in instruction_list:
		print(block.block_type)
		if block.block_type == "boolean_operator":
			print("-     Adding " + str(block) + " to operator list")
			operand_list.append(block)
		else:
			print("-     Adding " + str(block) + " to function list")
			function_list.append(block)


## Updates the options in both the foot add line dropdown and the in-line add line menu.
func refresh_command_dropdown():
	block_menu_drop_down.clear()
	print("- Updating ui")
	print(function_list)
	for block in function_list:
		print("-   Adding " + str(block.block_name) + " to menu")
		block_menu_drop_down.add_item(block.block_name)
		inline_block_menu.get_popup().add_item(block.block_name)
	block_menu_drop_down.selected = 0


## This method is called by signal when a new line needs to be added.
func add_line_button_pressed():
	add_line(block_menu_drop_down.selected)


## This method is called by signal when a new line needs to be added.
func _opon_item_selected(id :int) -> void:
	add_line(id)


## Adds a line of code at the end of the current [draft_code]. [br]
## [param_list_index] is the index of the deired instruction in the [function_list],
##    this is used for easier interface with the add code buttons.
func add_line(function_list_index):
	var prev_indent = 0 if len(draft_code) == 0 else draft_code[-1].get_next_indent()
	var new_line = instruction_line.new(
		prev_indent,
		function_list[function_list_index],
		[]
	)
	pull_code()
	draft_code.append(new_line)
	push_code()


## Removes the line of code at [param line]. [br]
## NOTE: The first line is line 0.
func remove_line(line :int):
	pull_code()
	draft_code.remove_at(line)
	push_code()


## Clears the complied code currently cached.
func clear_cache():
	compiled_code = []


## Updates the process name
func update_process_name(new_name :String = "Unknown Process", description :String = "Unknown process"):
	process_name = new_name
	process_label.text = " " + new_name.to_camel_case() + "(): "
	process_description_button.tooltip_text = description


## Hides the collapsible elements specified in [collapsable_nodes]
func _on_collapse_button_pressed() -> void:
	is_collapsed = not is_collapsed
	collapse_code_button.text = "\\/" if is_collapsed else "/\\"
	for this_node in collapsable_nodes:
		this_node.visible = not is_collapsed


## Shows the temporary help popup [br]
## TODO: Replace with with non-temporary solution
func _on_help_pressed() -> void:
	screen_dim()
	$HelpPopup.popup_centered()

## Shows the temporary controls popup
## TODO: Replace with with non-temporary solution
func _on_controls_pressed() -> void:
	screen_dim()
	$ControlPopup.popup_centered()


## Dims the screen
func screen_dim():
	screen_dimmer.show()


## Undims the screen
func screen_undim():
	screen_dimmer.hide()
