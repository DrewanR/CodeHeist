extends CanvasLayer

@export var slide_name :String
@export_multiline() var slide_description :String
@export_multiline() var slide_hint1 :String
@export_multiline() var slide_hint2 :String
@export_multiline() var slide_hint3 :String
@export_multiline() var slide_solution :String

@export_category("Relationships")
@export var popup :Node
@export var pupup_title :Node
@export var popup_body :Node
@export var screen_dimmer :Node


func _ready() -> void:
	$MarginContainer/VBoxContainer/HBoxContainer/DescriptionButton.visible = (slide_description != "")
	$MarginContainer/VBoxContainer/HBoxContainer/Hint1Button.visible = (slide_hint1 != "")
	$MarginContainer/VBoxContainer/HBoxContainer/Hint2Button.visible = (slide_hint2 != "")
	$MarginContainer/VBoxContainer/HBoxContainer/Hint3Button.visible = (slide_hint3 != "")
	$MarginContainer/VBoxContainer/HBoxContainer/SolutionButton.visible = (slide_solution != "")
	$MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/Label.text = "Slide " + str(TempSlideManager.current_slide+1) + "/" + str(TempSlideManager.get_slide_count())
	$MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/PreviousSlideButton.disabled = (TempSlideManager.current_slide == 0)
	$MarginContainer/VBoxContainer/PanelContainer/HBoxContainer/NextSlideButton.disabled = (TempSlideManager.current_slide == TempSlideManager.get_slide_count())
	
	if slide_name == "":
		slide_name = "Slide #" + str(TempSlideManager.get_current_slide()+1)
	
	await get_tree().process_frame
	if slide_description != "": _on_description_button_pressed()


func show_popup(title := "title", body := "body"):
	pupup_title.text = title
	popup_body.text = body + "\n\n[i]Click outside popup to close[/i]"
	screen_dim()
	print("Showing popup: " + title)
	popup.popup_centered()


func screen_dim():
	screen_dimmer.show()


func screen_undim():
	screen_dimmer.hide()


func _on_description_button_pressed() -> void:
	show_popup(
		slide_name,
		slide_description
	)


func _on_hint_1_button_pressed() -> void:
	show_popup(
		slide_name + ": Hint 1",
		slide_hint1
	)


func _on_hint_2_button_pressed() -> void:
	show_popup(
		slide_name + ": Hint 2",
		slide_hint2
	)


func _on_hint_3_button_pressed() -> void:
	show_popup(
		slide_name + ": Hint 3",
		slide_hint2
	)


func _on_solution_button_pressed() -> void:
	show_popup(
		slide_name + ": Solution",
		slide_solution
	)


func _on_previous_slide_button_pressed() -> void:
	TempSlideManager.swtich_to_prev_slide()


func _on_next_slide_button_pressed() -> void:
	TempSlideManager.swtich_to_next_slide()
