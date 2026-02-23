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

## Enum for the states of how a code will be treated: [br]
## DO: will result in the code being exectured,
## SKIP_1: will skip until the next control statement of proper indent,
## SKIP_ALL: will skip to the end of the indent.
enum PASS_STATES { DO, SKIP, SKIP_ALL}
## Enum for the type of layer in the indentStack
enum STACK_LAYER_TYPE { NONE, CONDITIONAL, ITERATIVE }

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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("primary_action"):
		run()

func run():
	print_line("Running...")
	editor.compile()
	## Indent stack, used to control indents and skipping, 
	var indent_stack := [stateStackLayer.new(0, STACK_LAYER_TYPE.NONE, PASS_STATES.DO)]
	# Iterates across every line
	#for line in compiled_code:
	var line_number = 0
	while line_number < len(compiled_code):
		var line = compiled_code[line_number]
		print("----")
		print(indent_stack)
		print(line)
		# Functions: ALL
		if (
			line.is_executable_function() and # The current line is executable
			indent_stack.back().state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack.back().indent == line.indent # The indents match
			):
			print("! Running " + line.primary_block.block_name)
			line_number += 1
			if line.valid_parameters() and line.uses_parameters():
				line.primary_block.execute(line.parameters)
			elif line.valid_parameters():
				line.primary_block.execute()
			else:
				print_line("> /!\\ Invalid parameter count...")
		# Conditionals: IF
		elif (
			line.is_selective_element() and # Is a selective block
			line.primary_block.block_ref == "if" and # And is an if statement
			indent_stack.back().state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack.back().indent == line.indent # The indents match
			):
			print("! Reached an if statement of indent " + str(line.indent))
			line_number += 1
			if line.primary_block.evaluate():
				print("  True")
				indent_stack.push_back(
					stateStackLayer.new(line.indent+1, STACK_LAYER_TYPE.CONDITIONAL, PASS_STATES.DO)
				)
			else:
				print("  False")
				indent_stack.push_back(
					stateStackLayer.new(line.indent+1, STACK_LAYER_TYPE.CONDITIONAL, PASS_STATES.SKIP)
				)
		# Conditionals: ELSE IF TODO: Test
		elif (
			line.is_selective_element() and # Is a selective block
			line.primary_block.block_ref == "elif" and # And is an else statement
			len(indent_stack) > 1 and # Indent stack is large enough for an else state to be possible
			indent_stack[-2].state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack[-2].indent == line.indent # The indents match
		):
			print("! Reached an else if statement of indent " + str(line.indent))
			line_number += 1
			# Scenario 1: Currently in "SKIP" state
			if indent_stack.back().state == PASS_STATES.SKIP:
				indent_stack.back().state = PASS_STATES.DO if line.primary_block.evaluate() else PASS_STATES.SKIP
			# Scenario 2: Currently in "DO" state
			else:
				indent_stack.back().state = PASS_STATES.SKIP_ALL
		# Conditionals: ELSE
		elif (
			line.is_selective_element() and # Is a selective block
			line.primary_block.block_ref == "else" and # And is an else statement
			len(indent_stack) > 1 and # Indent stack is large enough for an else state to be possible
			indent_stack[-2].state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack[-2].indent == line.indent # The indents match
		):
			print("! Reached an else statement of indent " + str(line.indent))
			line_number += 1
			indent_stack.back().state = PASS_STATES.DO if indent_stack.back().state == PASS_STATES.SKIP else PASS_STATES.SKIP_ALL
		# Skip conditions
		elif (
			indent_stack.back().state in [PASS_STATES.SKIP, PASS_STATES.SKIP_ALL] and
			indent_stack.back().indent == line.indent
		):
			line_number += 1
			print("skipped")
		# End indent block
		elif len(indent_stack) > 1:
			indent_stack.pop_back()
		else:
			line_number += 1

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
		# Case 2: multiple references. currently unused
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


class stateStackLayer:
	var indent :int
	var type :STACK_LAYER_TYPE
	var state :PASS_STATES
	
	func _init(_indent :int, _type :STACK_LAYER_TYPE, entry_state :PASS_STATES) -> void:
		indent = _indent
		type = _type
		state = entry_state
	
	func _to_string() -> String:
		return str(indent) + ": " + str(type) + " " + str(state)
