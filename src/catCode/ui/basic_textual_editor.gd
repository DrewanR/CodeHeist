extends TextEdit

## Signal emitted upon code compilation.
signal code_recompiled(new_compiled_code :Array[instruction_line])
## Signal emitted upon code update.
#signal code_updated

## You know it, you hate it, the usual hack
@export var parent :Node

## List containing logicBlocks. [br]
## These are the backend instructions containing within [res://src/catCode/logicBlocks/]
##    that inheret the logicalBlock class. [br]
## These are taken from the children of this class. [br][br]
## [br]View [docs/catCode.md] for more information.
var instruction_list :Array[logic_block] = []
## Dictionary containing the same information.
var instruction_dict :Dictionary[String, logic_block] = {}

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
	return new_code


func parse_line(text_line :String) -> instruction_line:
	var split_text = text_line.split("(")
	
	var command = split_text[0].remove_chars("\t ")
	var indent = split_text[0].count("\t")
	
	if instruction_dict.has(command) and len(split_text) > 1:
		print("- + command: '" + str(command) + "', indent: " + str(indent) + ", params: " + str(split_text[1].left(-1).split(",")))
		return instruction_line.new(indent, instruction_dict[command], split_text[1].left(-1).split(","))
	elif instruction_dict.has(command):
		print("- + command: '" + str(command) + "', indent: " + str(indent))
		return instruction_line.new(indent, instruction_dict[command])
	else:
		print("- ! command: '" + str(command) + "' not found.")
		return null


func update_instructions(new_list, new_dict):
	instruction_list = new_list
	instruction_dict = new_dict

func update_instruction_dict(_instruction_dict):
	instruction_dict = _instruction_dict

func update_instruction_list(_instuction_list):
	instruction_list = _instuction_list
