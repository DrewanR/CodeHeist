extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	position = round(CameraInformation.centre_point)
	zoom = Vector2(CameraInformation.zoom,CameraInformation.zoom)
