extends Control

@export var options :Dictionary[String,PackedScene] = {}

var cat_nodes = []

@onready var button = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/OptionButton
@onready var ui = $CanvasLayer


func _ready() -> void:
	for keys in options.keys():
		print(keys)
		button.add_item(keys)
		cat_nodes.append(options[keys])
	button.selected = -1


func _on_button_pressed() -> void:
	var instance = cat_nodes[button.selected].instantiate()
	add_child(instance)
	
	ui.queue_free()
