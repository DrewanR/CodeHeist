class_name generic_entity extends CharacterBody2D

# Variables
#===========================================

var type :String = "generic_entity"

var max_hp :int = 1 ## Max HP value
var hp :int = 1 ## Current HP value

var max_stability :int = 1 ## Max stability value
var stability :int = 1 ## Current stability value

var damagable :bool = true
var codable :bool = true
var allow_overflow :bool = false

# Signals
#===========================================

signal damage_received(amount :int, new_value :int)
signal healing_received(amount :int, new_value :int)
signal hp_changed(amount :int, new_value :int)

signal max_hp_changed(amount :int, new_value :int)

signal stability_decreased(amount :int, new_value :int)
signal stability_increased(amount :int, new_value :int)
signal stability_changed(amount :int, new_value :int)

signal max_stability_changed(amount :int, new_value :int)

# HP functions
#===========================================

## Explicitly damages character by integer [amount] [br]
## Emits signals: [hp_changed], [damage_received]
func damage(amount :int) -> void:
	if damagable:
		hp -= amount
		cap_hp()
		damage_received.emit(amount, hp)
		hp_changed.emit(-amount, hp)

## Explicitly heals character by integer [amount] [br]
## Emits signals: [hp_changed], [healing_received]
func heal(amount :int) -> void:
	if damagable:
		hp += amount
		cap_hp()
		healing_received.emit(amount, hp)
		hp_changed.emit(amount, hp)

## Changes hp by integer [amount] [br]
## Emits signal: [hp_changed]
func change_hp(amount :int) -> void:
	hp += amount
	cap_hp()
	hp_changed.emit(amount, hp)

## Sets HP to integer [amount] [br]
## Emits signal: [hp_changed]
func set_hp(value) -> void:
	var amount = value - hp
	hp = value
	cap_hp()
	hp_changed.emit(amount, hp)

## If [allow_overflow] is [false], prevents [hp] overflowing [max_hp],
## else, it emits signals for hp overflow. [br]
##
## WARNING: This does NOT handle HP underflow. [br]
## TODO: Implement hp overflow signals
##
## Emits signals: N/A
func cap_hp() -> void:
	# TODO: Implement signals
	hp = hp if allow_overflow else min(hp, max_hp)


# Max HP functions
#===========================================

## Sets max HP to integer [amount] [br]
## Emits signal: [max_hp_changed]
func set_max_hp(value) -> void:
	var amount = value - max_hp
	max_hp = value
	max_hp_changed.emit(amount, max_hp)

# HP functions
#===========================================

## Explicitly damages stability by integer [amount] [br]
## Emits signals: [stability_changed], [stability_decreased]
func decrease_stability(amount :int) -> void:
	if codable:
		stability -= amount
		cap_stability()
		if stability < 0:
			damage(-stability)
			stability = 0
		stability_decreased.emit(amount, stability)
		stability_changed.emit(-amount, stability)

## Explicitly heals stability by integer [amount] [br]
## Emits signals: [stability_changed], [stability_increased]
func increase_stability(amount :int) -> void:
	if codable:
		stability += amount
		cap_stability()
		stability_increased.emit(amount, stability)
		stability_changed.emit(amount, stability)

## Changes stability by integer [amount] [br]
## Emits signal: [stability_changed]
func change_stability(amount :int) -> void:
	stability += amount
	cap_stability()
	stability_changed.emit(amount, stability)

## Sets stability to integer [amount] [br]
## Emits signal: [stability_changed]
func set_stability(value) -> void:
	var amount = value - stability
	stability = value
	cap_stability()
	hp_changed.emit(amount, stability)

## If [allow_overflow] is [false], prevents [stability] overflowing [max_stability],
## else, it emits signals for stability overflow. [br]
##
## WARNING: This does NOT handle stability underflow. [br]
## TODO: Implement stability overflow signals
##
## Emits signals: N/A
func cap_stability() -> void:
	# TODO: Implement signals
	stability = stability if allow_overflow else min(stability, max_stability)


# Max stability functions
#===========================================

## Sets max stability to integer [amount] [br]
## Emits signal: [max_stability_changed]
func set_max_stability(value) -> void:
	var amount = value - max_stability
	max_stability = value
	max_stability_changed.emit(amount, max_stability)

# Utilities
#===========================================

func is_type(_type): return _type == type #or .is_type(type)
func     get_type(): return type

func is_damagable(): return damagable
