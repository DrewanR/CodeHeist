extends Node2D

@onready var text_editor = $testUI/MarginContainer/HSplitContainer/basicTextualEdit
@onready var graphical_editor = $testUI/MarginContainer/HSplitContainer/basicGraphicalEditor

func _on_text_to_graphical_button_pressed() -> void:
	var code = text_editor.compile()
	graphical_editor.set_code(code)
