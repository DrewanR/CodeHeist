extends Container

## Signal emitted upon code compilation.
signal code_recompiled(new_compiled_code :Array[instruction_line])
## Signal emitted upon code update.
#signal code_updated

## You know it, you hate it, the usual hack
@export var parent :Node

## List containing logicBlocks. [br]
## These are the backend instructions containing within [res://src/catCode/logicBlocks/]
##    that inherit the logicalBlock class. [br]
## These are taken from the children of this class. [br][br]
## [br]View [docs/catCode.md] for more information.
var instruction_list :Array[logic_block] = []
## Dictionary containing the same information.
var instruction_dict :Dictionary[String, logic_block] = {}

## The draft, local version of the code.
## This may include outdated parameters.
var draft_code :Array[instruction_line]

## The most recently successfully compiled code
var compiled_code :Array[instruction_line]

## References to all of the graphical_nodes
var instruction_nodes :Array[graphical_block]

## Node that all of the graphical_blocks will be a child of
@onready var code_container := $MarginContainer/VBoxContainer/CodeContainer

@onready var code_compile_button := $MarginContainer/HBoxContainer/SaveButton
@onready var code_revert_button := $MarginContainer/HBoxContainer/RevertButton

func _ready() -> void:
	parent.instructions_updated.connect(update_instructions)
	clear_cache()


## Updates draft_code to replect what is currently in the nodes
func compile() -> Array[instruction_line]:
	compiled_code = []
	pull_code()
	
	for line in draft_code:
		compiled_code.append(line)
	
	code_recompiled.emit(compiled_code)
	code_revert_button.visible = true
	return compiled_code


## Sets and pushes code from [param new_code] into draft_code
func set_code(new_code :Array[instruction_line], will_emit_signal :bool = false):
	draft_code = new_code
	push_code()
	
	if will_emit_signal: code_recompiled.emit(draft_code)

## Pushes code from draft code into the nodes. [br]
## WARNING: Does NOT update parameters.
func push_code():
	clear_nodes()
	print("> Pushing code...")
	for i in range(0, len(draft_code)):
		print("- " + str(i) + " " + str(draft_code[i]))
		var this_logic_block :logic_block = draft_code[i].primary_block
		var this_graphical_block :graphical_block = this_logic_block.ui_block.instantiate()
		instruction_nodes.append(this_graphical_block)
		code_container.add_child(this_graphical_block)
		this_graphical_block.bind_from_instruction(draft_code[i])


func pull_code():
	clear_draft_code()
	print("> Compiling code...")
	for i in range(0, len(instruction_nodes)):
		print("- " + str(i) + " " + str(instruction_nodes[i]))
		draft_code.append(instruction_nodes[i].get_instruction_line())

## Clears all of the nodes stored
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


func update_instructions(new_list, new_dict):
	instruction_list = new_list
	instruction_dict = new_dict


func update_instruction_dict(_instruction_dict):
	instruction_dict = _instruction_dict


func update_instruction_list(_instruction_list):
	instruction_list = _instruction_list


func revert_code():
	set_code(compiled_code)


func clear_cache():
	compiled_code = []
	code_revert_button.visible = false
