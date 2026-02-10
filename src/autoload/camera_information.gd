extends Node
signal zoom_changed

var centre_point :Vector2

var zoom :float = 1:
	get:
		return zoom
	set(value):
		zoom = value
		emit_signal("zoom_changed")
