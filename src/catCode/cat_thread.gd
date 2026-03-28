class_name cat_thread extends Node

## The node that spawned this thread
var manager :Node

## The node to output text
var text_output :Node

## Stability target
var stability_target :Node

## Node to output any errors to.
var error_output :Node

## Instruction dictionary
#var instruction_dict :Dictionary[String, logic_block]

## The priority of this thread, higher numbers will be prioritized.
## Valid numbers are between 0 and 999.
var priority :int

## Compiled code to be executed by this thread.
var compiled_code :Array[instruction_line] = []

## The status of the current thread
var thread_state :THREAD_STATES = THREAD_STATES.QUEUED

## Print information, view cat_code_manager
var debug_scenarios
enum DEBUG_OPTIONS { NEVER, EXTERNAL, BOTH }

## Enum for the states of how a code will be treated: [br]
## DO: will result in the code being executed,
## SKIP_1: will skip until the next control statement of proper indent,
## SKIP_ALL: will skip to the end of the indent.
enum PASS_STATES { DO, SKIP, SKIP_ALL}

## Enum for the type of layer in the indentStack
enum STACK_LAYER_TYPE { NONE, CONDITIONAL, ITERATIVE }

## The possible states of the thread. [br]
## QUEUED: Thread has been created, but hasn't started executing yet,
## ALIVE: Thread is currently in progress,
## DEAD: The thread has finished executing,
## KILLED: This thread has been forcibly ended.
enum THREAD_STATES { QUEUED, ALIVE, DEAD, KILLED}


func _ready() -> void:
	bind()
	execute()
	debug_output("Thread_info", "# Thread died: '" + name + "'")


## Constructs a thread. [br]
## [param _priority] Priority of this thread, maximum: 999.
func bind(_priority :int = 0 ) -> void:
	manager = get_parent()
	text_output = manager.text_output
	stability_target = manager.stability_target
	error_output = manager.error_output
	
	compiled_code = manager.compiled_code
	priority = min(_priority, 999)
	add_blank_line()
	
	debug_scenarios = manager.debug_scenarios
	
	name = "Thread_%03d_%s" % [priority, Time.get_ticks_usec()]
	debug_output("Thread_info", "# Thread created: '" + name + "'")


## Executes the compiled code of this thread.
func execute() -> void:
	# Sets the thread status to alive
	thread_state = THREAD_STATES.ALIVE
	## Indent stack, used to control indents and skipping, 
	var indent_stack := [stateStackLayer.new(0, STACK_LAYER_TYPE.NONE, PASS_STATES.DO, 0)]
	# Iterates across every line
	#for line in compiled_code:
	var line_number = 0
	debug_output("Line_light", "Running...")
	while line_number < len(compiled_code):
		var line = compiled_code[line_number]
		debug_output("Line_full","--Current Stack: " + str(indent_stack))
		debug_output("Line_light","  " + str(line))
		
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
			debug_output("Line_full","! Reached an if statement of indent " + str(line.indent))
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
			debug_output("Line_full","! Reached an else if statement of indent " + str(line.indent))
			line_number += 1
			indent_stack.back().rep += 1
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
			debug_output("Line_full","! Reached an else statement of indent " + str(line.indent))
			line_number += 1
			indent_stack.back().rep += 1
			indent_stack.back().state = PASS_STATES.DO if indent_stack.back().state == PASS_STATES.SKIP else PASS_STATES.SKIP_ALL
		
		# Iterables: REPEAT (initiation)
		elif (
			line.is_iterative_element() and # Is an iterative block
			line.primary_block.block_ref in ["repeat", "repeatForever"] and # And is a repeat statement
			indent_stack.back().state == PASS_STATES.DO and # The stack is currently in a "do" state
			indent_stack.back().indent == line.indent # The indents match
		):
			debug_output("Line_full","! Reached a repeat statement of indent " + str(line.indent))
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
			debug_output("Line_full","! Re-reached a repeat statement of indent " + str(line.indent))
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
			debug_output("Line_full","! End of loop section reached")
			
			if indent_stack.back().state == PASS_STATES.DO: # If in do state, continues within the loop
				debug_output("Line_full","    Jumping back to start")
				line_number = indent_stack.back().entry
			else: # Else: ends the loop
				debug_output("Line_full","    Proceeding onwards")
				indent_stack.pop_back()
		
		# Skip conditions
		elif (
			indent_stack.back().state in [PASS_STATES.SKIP, PASS_STATES.SKIP_ALL] and
			indent_stack.back().indent == line.indent
		):
			line_number += 1
			debug_output("Line_full","  Skipping " + line.primary_block.block_name)
		
		# End indent block, pops the current stack layer
		elif len(indent_stack) > 1 and indent_stack.back().type == STACK_LAYER_TYPE.CONDITIONAL:
			debug_output("Line_full","  Popping...")
			indent_stack.pop_back()
		
		# And if none of the above is true, the line is skipped
		else:
			debug_output("Line_full","  Advancing...")
			line_number += 1

	thread_state = THREAD_STATES.DEAD


func debug_output(type :String, message :String) -> void:
	if debug_scenarios[type] == DEBUG_OPTIONS.BOTH:
		print_line(message)
	elif debug_scenarios[type] == DEBUG_OPTIONS.EXTERNAL:
		print(message)


func debug_output_fixed(output_location :DEBUG_OPTIONS, message :String) -> void:
	if output_location == DEBUG_OPTIONS.BOTH:
		print_line(message)
	elif output_location == DEBUG_OPTIONS.EXTERNAL:
		print(message)


func print_line(text :String):
	manager.print_line(text)


func add_blank_line():
	var pass_block = manager.pass_logic_node
	compiled_code.append(instruction_line.new(0, pass_block))

## StateStackLayer:
## Stores a layer of the state stack used for iteration and selection.
## Acts as a struct.
class stateStackLayer:
	var indent :int ## Current indent
	var type :STACK_LAYER_TYPE ## The type of stack layer, determines if it is getting used by an if or repeat essentially
	var state :PASS_STATES ## Determines whether instructions should be skipped
	var rep :int ## Number of repeats completed if iterative, else the number elifs passed
	var entry :int ## The line this layer was enterred using
	
	func _init(_indent :int, _type :STACK_LAYER_TYPE, entry_state :PASS_STATES, _entry :int) -> void:
		indent = _indent
		type = _type
		state = entry_state
		entry = _entry
		rep = 0
	
	func _to_string() -> String:
		return "<" + str(indent) + ": " + STACK_LAYER_TYPE.keys()[type][0] + " state:" + str(state) + " rep:" + str(rep) + " entry:" + str(entry) + ">"
