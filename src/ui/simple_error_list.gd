extends TextEdit

const FOCUS_ON_ERROR = 5
const FOCUS_ON_MOUSE = 0.05

@export var parent :player_cat

var focus = 7.5
var mouse_over = false

var alpha = 0.0

func _ready() -> void:
	parent.major_error_occurred.connect(_new_error)

func _new_error(message) -> void:
	if text != "":
		text += "\n"
	text += message
	scroll_vertical = 1000
	focus = FOCUS_ON_ERROR

func _process(delta: float) -> void:
	if focus >= 0:
		focus -= delta
		alpha = lerp(alpha, 255.0, 0.15)
	else:
		alpha = lerp(alpha, 0.0, 0.05)
	
	if mouse_over:
		focus = FOCUS_ON_MOUSE
	
	modulate = Color8(255, 255, 255, round(alpha))


func _on_mouse_entered() -> void:
	print("over")
	mouse_over = true

func _on_mouse_exited() -> void:
	print("out")
	mouse_over = false
