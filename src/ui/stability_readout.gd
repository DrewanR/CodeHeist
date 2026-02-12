extends Label

@export var parent :generic_entity
@export var pre_text  :String = "SB: "
@export var post_text :String

@export var show_max :bool = true

var hp :int
var max_hp :int

func _ready() -> void:
	parent.stability_decreased.connect(_on_damage_received)
	parent.stability_increased.connect(_on_healing_received)
	parent.stability_changed.connect(_on_hp_change)
	
	parent.max_stability_changed.connect(_on_max_hp_change)
	
	hp = parent.hp
	max_hp = parent.max_hp


func _on_damage_received(amount, new_value):
	hp = new_value
	$AnimationPlayer.play("damaged")
	print(parent.get_name() + " took " + str(amount) + " damage")

func _on_healing_received(amount, new_value):
	hp = new_value
	$AnimationPlayer.play("healed")
	print(parent.get_name() + " was healed for " + str(amount) + "hp")

func _on_hp_change(amount, new_value):
	hp = new_value
	update_text()
	print(parent.get_name() + "'s HP changed by " + str(amount) + " to " + str(new_value))

func _on_max_hp_change(amount, new_value):
	max_hp = new_value
	update_text()
	print(parent.get_name() + "'s max HP changed by " + str(amount) + " to " + str(new_value))


func update_text():
	if show_max:
		text = pre_text + str(hp) + "/" + str(max_hp) + post_text
	else:
		text = pre_text + str(hp) + post_text
