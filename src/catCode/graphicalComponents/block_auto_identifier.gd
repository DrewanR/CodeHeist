extends Label

@export var parent :graphical_block

func _ready() -> void:
	parent.refresh.connect(refresh_label)

func refresh_label() -> void:
	text = parent.indentifier
