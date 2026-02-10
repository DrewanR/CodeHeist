extends Node2D
"""
	THIS WAS CANIBALISED FROM ANOTHER PROJECT
	I CHOSE NOT TO MAKE IT BETTER FOR IT STINKS
"""

var zoomLerpVal = 1
var positionLerpVal = 1

@export var parent   :Node
@export var basePriority :int = 0
@export var baseZoom :float = 4.0
@export var baseSpeed :float = 1.0

var currentInfluences = []

func _ready():
	parent = get_parent()
	CameraInformation.centre_point = parent.position
	CameraInformation.zoom = baseZoom

func _process(_delta):
	var index :int = 0
	var posXDone :bool = false
	var posYDone :bool = false
	var zoomDone :bool = false
	var zoomLerpDone :bool = false
	var positionLerpDone : bool = false
	# The next line is disgusting
	while not ((index == len(currentInfluences)) or (posXDone and posYDone and zoomDone and zoomLerpDone)):
		var rawInfo = currentInfluences[index]
		if currentInfluences[index].priority < basePriority:
			break
		if rawInfo.zoomEasingSpeed != -1.0 and !zoomLerpDone:
			zoomLerpVal = rawInfo.zoomEasingSpeed
			zoomLerpDone = true
		if rawInfo.positionEasingSpeed != -1.0 and !positionLerpDone:
			positionLerpVal = rawInfo.positionEasingSpeed
			positionLerpDone = true
		if rawInfo.usePositionX and !posXDone:
			CameraInformation.centre_point.x = lerp(CameraInformation.centre_point.x,rawInfo.position.x, positionLerpVal)
			posXDone = true
		if rawInfo.usePositionY and !posYDone:
			CameraInformation.centre_point.y = lerp(CameraInformation.centre_point.y,rawInfo.position.y, positionLerpVal)
			posYDone = true
		if rawInfo.useZoom and !zoomDone:
			CameraInformation.zoom = lerp(CameraInformation.zoom,rawInfo.zoom,zoomLerpVal)
			zoomDone = true
		index += 1
	if !posXDone:
		CameraInformation.centre_point.x = lerp(CameraInformation.centre_point.x,parent.position.x,positionLerpVal)
	if !posYDone:
		CameraInformation.centre_point.y = lerp(CameraInformation.centre_point.y,parent.position.y,positionLerpVal)
	if !zoomDone:
		CameraInformation.zoom = lerp(CameraInformation.zoom,baseZoom,zoomLerpVal)
	if !zoomLerpDone:
		zoomLerpVal = 1.0
	if !positionLerpDone:
		positionLerpVal = 1.0
	#print(CameraInformation.centre_point)
	"""
	if len(currentInfluences) == 0:
		defaultBehaviour()
	elif currentInfluences[0].priority >= basePriority:
		var rawInfo = currentInfluences[0]
		CameraInfo.centrePoint = lerp(CameraInfo.centrePoint,rawInfo.position,lerpVal)
		CameraInfo.zoom = lerp(CameraInfo.zoom,rawInfo.zoom,lerpVal)
	else:
		defaultBehaviour()
	"""

func _on_area_2d_area_exited(area):
	currentInfluences.erase(area)
	print("Left cam area " + area.to_string() + "\n of priority: " + str(area.priority))

func _on_area_2d_area_entered(area):
	for i in range(0,len(currentInfluences)):
		if area.CameraPriority >= currentInfluences[i].CameraPriority:
			currentInfluences.insert(i,area)
			return
	currentInfluences.append(area)
	print("Entered cam area " + area.to_string() + "\n of priority: " + str(area.priority))
