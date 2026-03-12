extends Node

## Parent node that this will control
@export var parent :Node

## Node that will implement editing of this manager
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

## Show instruction set on boot
@export var show_instruction_set := true

## Autorun states
enum RUN_OPTIONS { NEVER, READY, PROCESS, PRIMARY_ACTION, SECONDARY_ACTION}
@export var when_to_run: RUN_OPTIONS

## Compile options,
## Default will compile 
enum COMPILE_OPTIONS { NEVER, RUN, DEFAULT}
@export var when_to_compile: COMPILE_OPTIONS = COMPILE_OPTIONS.DEFAULT

## List containing logicBlocks. [br]
## These are the backend instructions containing within [res://src/catCode/logicBlocks/]
##    that inherit the logicalBlock class. [br]
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
## DO: will result in the code being executed,
## SKIP_1: will skip until the next control statement of proper indent,s
## SKIP_ALL: will skip to the end of the indent.
enum PASS_STATES { DO, SKIP, SKIP_ALL}
## Enum for the type of layer in the indentStack
enum STACK_LAYER_TYPE { NONE, CONDITIONAL, ITERATIVE }

## Signal emitted upon updating the instructions
signal instructions_updated(new_list :Array[logic_block], new_dict :Dictionary[String, logic_block])

func _ready() -> void:
	if when_to_compile == COMPILE_OPTIONS.DEFAULT:
		when_to_compile == COMPILE_OPTIONS.NEVER if when_to_run == RUN_OPTIONS.PROCESS else COMPILE_OPTIONS.RUN
	
	print_line("CatCodeManager Started!")
	update_instructions()
	editor.code_recompiled.connect(_on_compiled_code_received)
	
	if (show_instruction_set):
		print_line("-----\nINSTRUCTION LIST")
		print_instruction_list()
		print_line("-----\nINSTRUCTION DICTIONARY")
		print_instruction_dictionary()
		print_line("-----")
	
	match when_to_run:
		RUN_OPTIONS.READY:
			run()
		RUN_OPTIONS.PRIMARY_ACTION:
			print_line("Press [Z] to run!")
		RUN_OPTIONS.SECONDARY_ACTION:
			print_line("Press [X] to run!")
	
	editor.compile()

func _process(_delta: float) -> void:
	if when_to_run == RUN_OPTIONS.PROCESS:
		run()
	elif when_to_run == RUN_OPTIONS.SECONDARY_ACTION and Input.is_action_just_pressed("secondary_action"):
		run()
	elif when_to_run == RUN_OPTIONS.PRIMARY_ACTION and Input.is_action_just_pressed("primary_action"):
		run()

func run():
	if when_to_run != RUN_OPTIONS.PROCESS: print_line("Running...")
	if when_to_compile == COMPILE_OPTIONS.RUN: editor.compile()
	#editor.compile()
	
	## Indent stack, used to control indents and skipping, 
	var indent_stack := [stateStackLayer.new(0, STACK_LAYER_TYPE.NONE, PASS_STATES.DO, 0)]
	# Iterates across every line
	#for line in compiled_code:
	var line_number = 0
	print("Running...")
	while line_number < len(compiled_code):
		var line = compiled_code[line_number]
		print("--Current Stack: " + str(indent_stack))
		print("  " + str(line))
		
		# Functions: ALL
		if (
			line.is_executable_function() and # The current line is executable
			indent_stack.back().state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack.back().indent == line.indent # The indents match
			):
			#print("! Running " + line.primary_block.block_name)
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
			#print("! Reached an if statement of indent " + str(line.indent))
			line_number += 1
			if line.primary_block.evaluate(line.parameters):
				#print("  True")
				indent_stack.push_back(
					stateStackLayer.new(line.indent+1, STACK_LAYER_TYPE.CONDITIONAL, PASS_STATES.DO, line_number)
				)
			else:
				#print("  False")
				indent_stack.push_back(
					stateStackLayer.new(line.indent+1, STACK_LAYER_TYPE.CONDITIONAL, PASS_STATES.SKIP, line_number)
				)
		
		# Conditionals: ELIF TODO: Test
		elif (
			line.is_selective_element() and # Is a selective block
			line.primary_block.block_ref == "elif" and # And is an else statement
			len(indent_stack) > 1 and # Indent stack is large enough for an else state to be possible
			indent_stack[-2].state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack[-2].indent == line.indent # The indents match
		):
			#print("! Reached an else if statement of indent " + str(line.indent))
			line_number += 1
			indent_stack.back().acc += 1
			# Scenario 1: Currently in "SKIP" state
			if indent_stack.back().state == PASS_STATES.SKIP:
				indent_stack.back().state = PASS_STATES.DO if line.primary_block.evaluate(line.parameters) else PASS_STATES.SKIP
			# Scenario 2: Currently in "DO" state
			else:
				indent_stack.back().state = PASS_STATES.SKIP_ALL
		
		# Conditionals: ELSE
		elif (
			line.is_selective_element() and # Is a selective block
			line.primary_block.block_ref == "else" and # And is an else statement
			(
				len(indent_stack) > 1 and # Indent stack is large enough for an else state to be possible
				indent_stack[-2].state == PASS_STATES.DO and # The stack is currently in a "do" state
				indent_stack[-2].indent == line.indent # The indents match
			)
		):
			#print("! Reached an else statement of indent " + str(line.indent))
			line_number += 1
			indent_stack.back().acc += 1
			indent_stack.back().state = PASS_STATES.DO if indent_stack.back().state == PASS_STATES.SKIP else PASS_STATES.SKIP_ALL
		
		# Iterables: REPEAT (initiation)
		elif (
			line.is_iterative_element() and # Is an iterative block
			line.primary_block.block_ref in ["repeat", "repeatForever"] and # And is a repeat statement
			indent_stack.back().state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack.back().indent == line.indent # The indents match
		):
			#print("! Reached a repeat statement of indent " + str(line.indent))
			# Do not incrment line
			indent_stack.push_back(
				stateStackLayer.new(line.indent+1, STACK_LAYER_TYPE.ITERATIVE, PASS_STATES.DO, line_number)
			)
			#indent_stack.back().entry = line_number - 1
		
		# Iterables: REPEAT (evaluation)
		elif (
			line.is_iterative_element() and # Is an iterative block
			line.primary_block.block_ref in ["repeat", "repeatForever"] and # And is a repeat statement
			len(indent_stack) > 1 and # Indent stack is large enough for this state to be possible
			indent_stack[-2].state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack[-2].indent == line.indent # The indents match
		):
			print("! Re-reached a repeat statement of indent " + str(line.indent))
			line_number += 1
			indent_stack.back().rep += 1 # Increment accumulator
			if line.primary_block.evaluate([line.parameters[0], indent_stack.back()]):
				print("  Loop continuing...")
				indent_stack.back().state = PASS_STATES.DO
			else:
				print("  Loop ending...")
				indent_stack.back().state = PASS_STATES.SKIP_ALL
			
			if line.primary_block.should_wait_for_next_frame(): # Waits for next frame if instructed to do so
				await get_tree().process_frame
		
		# Iterables: ENDLOOP
		elif (
			indent_stack.back().type == STACK_LAYER_TYPE.ITERATIVE and # Is in the iterative block.
			line.indent + 1 == indent_stack.back().indent # Indent is 1 less than before.
		):
			print("! End of loop section reached")
			
			if indent_stack.back().state == PASS_STATES.DO: # If in do state, continues within the loop
				print("    Jumping back to start")
				line_number = indent_stack.back().entry
			else: # Else: ends the loop
				print("    Proceding onwards")
				indent_stack.pop_back()
		
		# Skip conditions
		elif (
			indent_stack.back().state in [PASS_STATES.SKIP, PASS_STATES.SKIP_ALL] and
			indent_stack.back().indent == line.indent
		):
			line_number += 1
			print("  Skipping " + line.primary_block.block_name)
		
		# End indent block, pops the current stack layer
		elif len(indent_stack) > 1 and indent_stack.back().type == STACK_LAYER_TYPE.CONDITIONAL:
			print("  Popping...")
			indent_stack.pop_back()
		
		# And if none of the above is true, the line is skipped
		else:
			print("  Advancing...")
			line_number += 1

## Updates the blocks in both the instruction dictionary and list
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

func _on_compiled_code_received(new_code):
	compiled_code = new_code


class stateStackLayer:
	var indent :int
	var type :STACK_LAYER_TYPE
	var state :PASS_STATES
	var rep :int
	var entry :int
	
	func _init(_indent :int, _type :STACK_LAYER_TYPE, entry_state :PASS_STATES, _entry :int) -> void:
		indent = _indent
		type = _type
		state = entry_state
		entry = _entry
		rep = 0
	
	func _to_string() -> String:
		return "<" + str(indent) + ": " + STACK_LAYER_TYPE.keys()[type][0] + " state:" + str(state) + " rep:" + str(rep) + " entry:" + str(entry) + ">"
