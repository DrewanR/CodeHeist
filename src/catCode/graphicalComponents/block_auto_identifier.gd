extends Label

@export var parent :Control

func _ready() -> void:
	parent.refresh.connect(refresh_label)

func refresh_label() -> void:
	text = parent.indentifier
