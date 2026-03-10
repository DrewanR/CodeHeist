extends Control

@export var options :Dictionary[String,String] = {}

var paths = []

@onready var button = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var ui = $CanvasLayer


func _ready() -> void:
	for keys in options.keys():
		print(keys)
		button.add_item(keys)
		paths.append(options[keys])
	button.selected = -1


func _on_button_pressed() -> void:
	print("Load " + paths[button.selected])
	var scene = load(paths[button.selected])
	var instance = scene.instantiate()
	add_child(instance)
	
	ui.queue_free()
