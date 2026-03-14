class_name code_manager extends Node

@export_group("Relationships")

## Parent node that this will control
@export var parent :Node

## Node that will implement editing of this manager
@export var editor :Node

## Node to output any text to.
@export var text_output :Node

@export_subgroup("Optional:")

## Source of instruction nodes. [br]
## NOTE: If left blank, this will default to self
@export var instruction_source :Node = self

## Stability target [br]
## NOTE: If left blank, this will default to the [parent] node
@export var stability_target :Node

## Node to output any errors to. [br]
## NOTE: If left blank, this will default to the [text_output] node
@export var error_output :Node = text_output

@export_group("Execution options")

## Auto-run states
@export var when_to_run: RUN_OPTIONS
enum RUN_OPTIONS { NEVER, READY, PROCESS, PRIMARY_ACTION, SECONDARY_ACTION}

## Compile options, [br]
## NEVER: Will never compile, use if another node handles compilation.
## RUN: Will compile when.
## DEFAULT: Will infer behavior from auto-run. [br]
## 
## WARNING: Compiling will kill all the current threads
@export var when_to_compile :COMPILE_OPTIONS = COMPILE_OPTIONS.DEFAULT
enum COMPILE_OPTIONS { NEVER, RUN, DEFAULT}

## The maximum number of threads that can exist simultaneously. [br]
## WARNING: Multiple threads are untested.
@export var maximum_threads :int = 1

## Thread overflow behavior.
## NEVER_REPLACE: Never override the existing threads, will disregard the new process.
## ALWAYS_REPLACE: Will insert the new thread, killing the lowest priority (this may
##                 potentially kill the new process before it starts).
@export var thread_overflow_behavior := THREAD_OVERFLOW_BEHAVIORS.NEVER_REPLACE
enum THREAD_OVERFLOW_BEHAVIORS { NEVER_REPLACE, ALWAYS_REPLACE}

## The scenarios in which things are printed
@export var debug_scenarios := {
	"Instruction_set": DEBUG_OPTIONS.BOTH,
	"Construction": DEBUG_OPTIONS.EXTERNAL,
	"Thread_info": DEBUG_OPTIONS.NEVER,
	"Line_light": DEBUG_OPTIONS.NEVER,
	"Line_full": DEBUG_OPTIONS.NEVER
}
enum DEBUG_OPTIONS { NEVER, EXTERNAL, BOTH }

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
## Note: This class should never compile code
var compiled_code :Array[instruction_line] = []

## Array for storing the thread instances,
## These threads are used to separate out the running of code from the manager.
## Typically, only one thread will exist at once. All threads are destroyed when
##    code is recompiled. 
var threads :Array[cat_thread] = []

## Preload the cat_thread node
var cat_thread_node = preload("res://src/catCode/cat_thread.tscn")

## Signal emitted upon updating the instructions
signal instructions_updated(new_list :Array[logic_block], new_dict :Dictionary[String, logic_block])

func _ready() -> void:
	if when_to_compile == COMPILE_OPTIONS.DEFAULT:
		when_to_compile = COMPILE_OPTIONS.NEVER if when_to_run == RUN_OPTIONS.PROCESS else COMPILE_OPTIONS.RUN
	
	print_line("CatCodeManager Started!")
	update_instructions()
	editor.code_recompiled.connect(_on_compiled_code_received)
	
	debug_output("Instruction_set", "-----\nINSTRUCTION LIST")
	print_instruction_list(debug_scenarios["Instruction_set"])
	debug_output("Instruction_set", "-----\nINSTRUCTION DISCTIONARY")
	print_instruction_dictionary(debug_scenarios["Instruction_set"])
	debug_output("Instruction_set", "-----")
	
	match when_to_run:
		RUN_OPTIONS.READY:
			run_script()
		RUN_OPTIONS.PRIMARY_ACTION:
			print_line("Press [Z] to run!")
		RUN_OPTIONS.SECONDARY_ACTION:
			print_line("Press [X] to run!")
	
	editor.compile()

func _process(_delta: float) -> void:
	clean_threads()

	if when_to_run == RUN_OPTIONS.PROCESS:
		run_script()
	elif when_to_run == RUN_OPTIONS.SECONDARY_ACTION and Input.is_action_just_pressed("secondary_action"):
		run_script()
	elif when_to_run == RUN_OPTIONS.PRIMARY_ACTION and Input.is_action_just_pressed("primary_action"):
		run_script()

## Spawns and executes a thread, if applicable.
func run_script():
	if when_to_run != RUN_OPTIONS.PROCESS: print_line("Running...")
	if when_to_compile == COMPILE_OPTIONS.RUN: editor.compile()
	#editor.compile()
	

	# Case 1: below maximum thread count
	if (len(threads) < maximum_threads):
		create_thread()
	# Case 2: 
	elif (
		len(threads) == maximum_threads and 
		thread_overflow_behavior == THREAD_OVERFLOW_BEHAVIORS.ALWAYS_REPLACE
	):
		create_thread()


## Removes and queue_free()s all the dead threads
func clean_threads():
	var index = 0
	while index < len(threads):
		if threads[index].thread_state == cat_thread.THREAD_STATES.DEAD:
			kill_thread(index)
		else:
			index += 1


## Create Thread
func create_thread():
	# Creates the new thread
	var new_thread = cat_thread_node.instantiate()

	# Inserts it at the appropriate point
	for i in range(0,len(threads)):
		if threads[i].priority <= new_thread.priority:
			threads.insert(i, new_thread)
			return
	threads.append(new_thread)

	# Adds child
	add_child(new_thread)


## Kills a thread in the thread array at [param index].
## This will both remove the array item and queue the thread free.
func kill_thread(index :int):
	var thread = threads.pop_at(index)
	thread.thread_state = thread.THREAD_STATES.KILLED
	thread.queue_free()


## Updates the blocks in both the instruction dictionary and list
func update_instructions(source := self) -> void:
	# Updates instruction list
	debug_output("Construction", "- Updating the instruction set...")
	instruction_list = get_logic_blocks(source)
	
	# Creates new dictionary from the instruction list
	debug_output("Construction", "-   Updating dictionary...")
	for this_block in instruction_list:
		# Case 1: only one reference
		if this_block.get_reference_count() == 1:
			instruction_dict.set(this_block.get_primary_reference(), this_block)
			debug_output("Construction", "-     " + this_block.get_primary_reference() + " added to instruction dictionary")
		# Case 2: multiple references. currently unused
		else:
			pass # TODO: cry
	
	# Emits signal to update nodes of a new instruction set
	instructions_updated.emit(instruction_list, instruction_dict)


## Logic blocks are stored as children of this node, this function fetches theme all. [br]
## Due to quirks in the engine, it was determined that using names was the best way of doing this...
func get_logic_blocks(source := self) -> Array[logic_block]:
	debug_output("Construction", "-   Updating instruction list...")
	var children = source.get_children()
	var logical_children :Array[logic_block] = []
	for child in children:
		if child.name.split("_")[0] == "logicBlock":
			debug_output("Construction", "-     Added " + child.name)
			logical_children.append(child)
		else:
			debug_output("Construction", "-     Rejected " + child.name)
	return logical_children


## Prints line [message] to text_output node
func print_line(message) -> void:
	if text_output == null:
		print("- " + message)
	else:
		text_output.print_line(message)
		print("> " + message)


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


## Prints the current instruction list
func print_instruction_list(output_location :DEBUG_OPTIONS = DEBUG_OPTIONS.BOTH) -> void:
	for i in range(0, len(instruction_list)):
		var this_item = instruction_list[i]
		debug_output_fixed(output_location, "[" + str(i) + "] " + this_item.name + ": " + this_item.get_primary_reference())


func print_instruction_dictionary(output_location :DEBUG_OPTIONS = DEBUG_OPTIONS.BOTH) -> void:
	var keys = instruction_dict.keys()
	for this_key in keys:
		var this_item = instruction_dict[this_key]
		debug_output_fixed(output_location, "[" + this_key + "] " + this_item.name + ": " + this_item.get_primary_reference())


func _on_compiled_code_received(new_code):
	compiled_code = new_code
