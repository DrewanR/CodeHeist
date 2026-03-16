extends TextEdit

## Signal emitted upon code compilation.
signal code_recompiled(new_compiled_code :Array[instruction_line])
## Signal emitted upon code update.
#signal code_updated

## You know it, you hate it, the usual hack
@export var parent :Node

## If true, the code will compile whenever focus is lost
@export var compile_on_lost_focus := true

## List containing logicBlocks. [br]
## These are the backend instructions containing within [res://src/catCode/logicBlocks/]
##    that inherit the logicalBlock class. [br]
## These are taken from the children of this class. [br][br]
## [br]View [docs/catCode.md] for more information.
var instruction_list :Array[logic_block] = []
## Dictionary containing the same information.
var instruction_dict :Dictionary[String, logic_block] = {}

## This is used as a fallback for invalid operators. This should be false.
var false_fallback := preload("res://src/catCode/logicBlocks/nodes/boolean_value.tscn")

func _ready() -> void:
	parent.instructions_updated.connect(update_instructions)

## Compiles the current code [br]
## Emits [signal code_recompiled] and returns the new compiled code
func compile() -> Array[instruction_line]:
	var new_code :Array[instruction_line] = []
	
	print("- Compiling Code:")
	for text_line in text.split("\n"):
		var parsed_line = parse_line(text_line)
		
		if parsed_line != null: new_code.append(parsed_line)
	
	code_recompiled.emit(new_code)
	print("- Code compiled.")
	return new_code


func parse_line(text_line :String) -> instruction_line:
	var split_text = text_line.split("(", true, 1)
	
	var command = split_text[0].remove_chars("\t ")
	var indent = split_text[0].count("\t")
	
	if not instruction_dict.has(command): # First, returns if there is not a corresponding instruction
		print("- ! command: '" + str(command) + "' not found.")
		return null
	var block := instruction_dict[command]
	if block.block_type == "conditional_block":
		if block.is_using_boolean_operator() and len(split_text) > 1:
			print("- + conditio: '" + str(command) + "', indent: " + str(indent) + ", ops: " + str(split_text[1].left(-1)))
			return instruction_line.new(indent, block, get_operator(str(split_text[1].left(-1))))
		else:
			print("- + conditio: '" + str(command) + "', indent: " + str(indent))
			return instruction_line.new(indent, block)
	else:
		if len(split_text) > 1:
			print("- + function: '" + str(command) + "', indent: " + str(indent) + ", params: " + str(split_text[1].left(-1).split(",")))
			return instruction_line.new(indent, block, split_text[1].left(-1).split(","))
		else:
			print("- + function: '" + str(command) + "', indent: " + str(indent))
			return instruction_line.new(indent, block)


## Parses the op_code into a full boolean operator
func get_operator(op_code :String) -> Array:
	print("      parsing " + op_code)
	var split_op_code = op_code.split("(", true, 1)
	if len(split_op_code) > 1 and instruction_dict.has(split_op_code[0]):
		print("        got: " + split_op_code[0])
		print("             " + str(split_op_code[1].left(-1).split(",")))
		return [instruction_dict[split_op_code[0]], split_op_code[1].left(-1).split(",")]
	elif instruction_dict.has(split_op_code[0]):
		print("        got: " + split_op_code[0])
		return [instruction_dict[split_op_code[0]]]
	else:
		print("        invalid, replacing with false.")
		return [false_fallback.instantiate()]

func update_instructions(new_list, new_dict):
	instruction_list = new_list
	instruction_dict = new_dict

func update_instruction_dict(_instruction_dict):
	instruction_dict = _instruction_dict

func update_instruction_list(_instruction_list):
	instruction_list = _instruction_list

# Focus and lost focus code
#============================

const FOCUS_ON_OUTPUT = 5
const FOCUS_ON_MOUSE = 0.05

## If true, this node will become transparent when focus is lost.
@export var fade_on_lost_focus = true

var focus = FOCUS_ON_OUTPUT
var mouse_over = false

var alpha = 0.0

func _process(delta: float) -> void:
	if focus >= 0:
		focus -= delta
		alpha = lerp(alpha, 255.0, 0.15)
	elif focus >= -5:
		focus -= delta
		alpha = lerp(alpha, 100.0, 0.05)
	else:
		alpha = lerp(alpha, 0.0, 0.05)
	
	if mouse_over:
		focus = FOCUS_ON_MOUSE
	
	if not fade_on_lost_focus:
		focus = FOCUS_ON_MOUSE
	
	modulate = Color8(255, 255, 255, round(alpha))
	
	if Input.is_action_just_pressed("ui_cancel"):
		focus_lost()

func focus_lost():
	release_focus()
	mouse_over = false
	compile()
	get_tree().paused = false

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	focus_lost()

func _on_focus_entered() -> void:
	get_tree().paused = true
