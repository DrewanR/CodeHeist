extends Label

@export var parent :generic_entity
@export var pre_text  :String
@export var post_text :String

var hp :int
var max_hp :int

func _ready() -> void:
	parent.damage_received.connect(_on_damage_received)
	parent.healing_received.connect(_on_healing_received)
	parent.hp_changed.connect(_on_hp_change)
	
	parent.max_hp_changed.connect(_on_max_hp_change)
	
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
	text = pre_text + str(hp) + "/" + str(max_hp) + post_text
