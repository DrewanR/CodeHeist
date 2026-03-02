Note: In the godot style guide difference cases in variables correlate to different things, as a general rule of thumb `camelCase` refers to nodes, whereas `snake_case` refers to classes and variables. Where possible, this convention has been followed.

# Cat Code

CatCode was planned as a Scratch-like programming language specially designed to interface with playerCat.

> This section will first describe the overall structure of the systems that collectively became known as catCode and the rationale behind this. It will then describe how code is interpreted and executed by the the `codeManager` node, followed by a more detailed explanation of the individual components of the language such as selection and iteration. Finally it will describe the UI used to code things.

## Overview

> ![](assets/catCodeOverview.svg)
>
> Simplified overview of the components that make up the catCode system.

As shown above, the `codeManager` is instantiated as a child node of what it controls, in most cases this will be a player. This is done this way to allow the codeManager can be applied to other nodes, provided valid logical blocks are provided. The instruction set is defined by `logicBlock`s (using the `logic_block` set of classes, described later) instantiated as children of the codeManager. This method was done to allow for drag and drop editing of instruction sets within the godot editor.

The editor and logs are separated out from the `codeManager` node to follow object orientated design good practice. This proved to be a good decision very quickly as it allowed for the interpretation of code to be separated out from the compilation of it, which meant that during development a simpler text based language could be created. The direct communication between the editor and manager will be detailed further throughout this section.

Finally, there is the instruction set. This is defined by two variables, the `instruction_list`, which contains a list of all the instructions available to a given instance of the code manager, and the `instruction_dict` which contains all the possible commands and references to their `LogicBlock`s.

The following table contains a brief guide to what everything does.

> | Node(s) | Variable | Responsibilities |
> | ------- | -------- | ---------------- |
> | Player Cat | `parent` | Executes movement functions such as `jump()` |
> | Code Manager | *this node* | Runs code, calling all methods. Constructs instruction set. |
> | Code Editor | `editor` | Edits and compiles the code. |
> | Log | `text_output` | Handles text outputs, implementing method `print_line(message)`. | 
> | Error Log | `error_output` | Outputs error messages, if unassigned, this will be handled by the logger. |
> | Stability Target | `stability_target` | The entity that will be damaged by errors. |
> | Instruction Source | `instruction_source` | The children of this node are used to compile the instruction set |
> | Logic blocks | *N/A* | Stores both the metadata and methods for a block. |
>
> Table of responsibilities for each node, and how they are referenced by the `codeManager`

## The `logic_block` set of Classes

The `logic_block` set of classes, sometimes semantically called the LogicalBlocks, and handle the backend functionality of the blocks. These store the metadata and implementation of the function that operate a given block. There are multiple different types of blocks, explained below and in the class diagram below. Godot does have interfaces, instead abstract classes had to be used, nor does it support multiple inheritance, this is partially the reason for the messy implementation.

In terms of file structure, the "logicBlock" directory is separated into two folders: "nodes" and "scripts", with superclasses stored with the other catCode superclasses. The nodes (.tscn files) were separated off like this so that there is a folder containing only the nodes that can be dragged on dropped to add them to a codeManager.

> ![](assets/catCode-LogicalBlocks-ClassDiagram.svg)
>
> Class diagram detailing the LogicalBlock class group.
>
> Note: This only shows a limited number of subclasses. `@Export` variables (editable by an instance node in the editor) are denoted by an "@". Abstract classes and methods are listed in italix. The most important variables and methods are in bold. All methods and variables, due to the nature of gd-script, are public so the private and public symbols have been omitted. 
>
> *Not a true abstract implementation, rather the default implementation of the function throws an in-game error.

### Logic_block

Logic block is main superclass. It defines a few abstract methods, that other classes use. Most of the methods declared here are defined in the next layer of classes. This superclass exists to define the core attributes and to allow stricter typing within variables later on.

### Function_block

Function block is used for functions. Like all the other block categories, this superclass adds `block_ref` a string that identifies the block. Also similar to all the other classes, the `on_ready()` function sets the node's name to `"logicBlock_function_" + block_name.to_camel_case()` and the parent (if not overridden in the .tscn) to the `parent` node, which is the origin of this variable's name. Unless specified otherwise, this is the same in the other logical blocks.

Parameters are specified in the `params` array semantically, however only considered in the `execute()` function. The `execute()` function is the only remaining function (or variable) left to be defined by the subclasses that implement the catCode functions. Parameters are provided to the execute array using an array due to the structure of "compiled" code.

### Conditional_block

The conditional_block superclass was constructed for `if`, `elif` and `else` statements. Ultimately all of these methods could be defined using the `if_conditional`, however this class was kept in case future statements were added that could not be done using this subclass.

The logic for conditional blocks are mostly handled by the code manager, except for evaluation which is handled by a subclass. The `evaluate()` method, when `uses_boolean_operator()` is true, uses the boolean operator specified within the first slot (index 0) of `args` array with any other parameters provided in the second slot.

### Boolean_operator

### Iteration_block

## Creating an Instruction Set

> ![alt text](assets/screenshots/2026-03-02-14-05a.png)
>
> Example instance of a codeManager. This exact example was from the self contained first prototype of this system.

The instruction set, for the level designer, is defined by dragging and dropping `logic_block` nodes from the exploring onto the `codeManager` node. Example shown above. Certain nodes may need configuration within the inspector. When the codeManager is instantiated, the `update_instructions()` is called which creates the `instruction_list` and `instruction_dict`. 

First, the `instruction_list` is created by creating an array with a reference to each of the instanced logicBlock nodes. This function is able to determine that a block is an instruction block using the nodes name. All the blocks use the naming scheme `logicalBlock_<type>_<name>`, and the below method takes advantage of this.

```gd
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
```

From this, the `instruction_dict` dictionary is created from the list by iterating across add of the elements executing `instruction_dict.set(this_block.get_primary_reference(), this_block)`. Beforehand, the function checks to see the reference count. At present there are no blocks that have multiple references, which means there is no implementation for this scenario.

Finally, the `instructions_updated(new_list :Array[logic_block], new_dict :Dictionary[String, logic_block])` signal is emitted, which carries both the list and dictionary. The finished list and dictionary for the above example is shown below. Note that this is a aggregational relationship not a compositional one, meaning that is either of the variables are updated, the nodes are not unloaded.

> ![](assets/screenshots/2026-03-02-14-25a.png)
> 
> Completed `instruction_list` and `instruction_dict`. Note: each node is presented by the string `<name>: ref`, 

## Compiling code

## Interpreting Code

## The Graphical Editor