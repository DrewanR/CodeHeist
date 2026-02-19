extends Node

## Parent node that this will control
@export var parent :Node

## Node that will implement editting of this manager
@export var editor :Node

## Node to output any text to.
@export var text_output :Node

## Source of instruction nodes. [br]
## NOTE: If left blank, this will default to self
@export var instruction_source :Node = self

## Stability target [br]
## NOTE: If left blank, this will default to the [parent] node
@export var stability_target :Node

## Node to output any errors to. [br]
## NOTE: If left blank, this will default to the [text_output] node
@export var error_output :Node = text_output

## List containing logicBlocks. [br]
## These are the backend instructions containing within [res://src/catCode/logicBlocks/]
##    that inheret the logicalBlock class. [br]
## These are taken from the children of this class. [br][br]
## [br]View [docs/catCode.md] for more information.
var instruction_list :Array[logic_block] = []
## Dictionary containing the same information.
var instruction_dict :Dictionary[String, logic_block] = {}
# Both were used as please cats have mercy, this is already hell to deal with.

## Compiled code. [br]
## Note: This function should never compile code
var compiled_code :Array[instruction_line] = []

## Signal emitted upon updating the instructions
signal instructions_updated(new_list :Array[logic_block], new_dict :Dictionary[String, logic_block])

func _ready() -> void:
	print_line("CatCodeManager Started!")
	update_instructions()
	editor.code_recompiled.connect(_on_compiled_code_recieved)
	
	print_line("---")
	print_instruction_list()
	print_line("---")
	print_instruction_dictionary()
	print_line("---")
	print_line("Debug: Press [Z] to run!")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary_action"):
		run()

func run():
	print_line("Running...")
	editor.compile()
	for line in compiled_code:
		print("! Running " + line.primary_block.block_name)
		line.primary_block.execute()

## Updates the blocks in both the instruciton dicitonary and list
func update_instructions(source := self) -> void:
	# Updates instruction list
	print("- Updating the instruction set...")
	instruction_list = get_logic_blocks(source)
	
	# Creates new dictionary from the instruction list
	print("-   Updating dictionary...")
	for this_block in instruction_list:
		# Case 1: only one reference
		if this_block.get_reference_count() == 1:
			instruction_dict.set(this_block.get_primary_reference(), this_block)
			print("-     " + this_block.get_primary_reference() +" added to instruction dictionary")
		# Case 2: multiple references
		else:
			pass # TODO: cry
	
	# Emits signal to update nodes of a new instruction set
	instructions_updated.emit(instruction_list, instruction_dict)


## Logic blocks are stored as children of this node, this function fetches theme all. [br]
## Due to quirks in the engine, it was determined that using names was the best way of doing this...
func get_logic_blocks(source := self) -> Array[logic_block]:
	print("-   Updating instruction list...")
	var children = source.get_children()
	var logical_children :Array[logic_block] = []
	for child in children:
		if child.name.split("_")[0] == "logicBlock":
			print("-     Added " + child.name)
			logical_children.append(child)
		else:
			print("-     Rejected " + child.name)
	return logical_children


## Prints line [message] to text_output node
func print_line(message) -> void:
	if text_output == null:
		print("- " + message)
	else:
		text_output.print_line(message)
		print("> " + message)


## Prints the current instruction list
func print_instruction_list() -> void:
	for i in range(0, len(instruction_list)):
		var this_item = instruction_list[i]
		print_line("[" + str(i) + "] " + this_item.name + ": " + this_item.get_primary_reference())

func print_instruction_dictionary() -> void:
	var keys = instruction_dict.keys()
	for this_key in keys:
		var this_item = instruction_dict[this_key]
		print_line("[" + this_key + "] " + this_item.name + ": " + this_item.get_primary_reference())

func _on_compiled_code_recieved(new_code):
	compiled_code = new_code
