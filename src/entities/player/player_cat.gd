class_name player_cat extends generic_entity

# Constants
#===========================================

# Meta constants (constants used for constants)
const SLIPMOD := 3.0 ## Meta constant that controls the slipiness of the physics, higher values result in slower acc and dec
const JUMP_VELOCITY := -210.0 ## The vertical impulse given by a jump.
const MAX_SPEED := 160.0 ## The threshold at which the player is considered to be going at max speed.

# Health
const MAX_HP := 3 ## The max hp available
const STARTING_HP := 3 ## The starting hp
const MAX_STABILITY := 2 ## Maximum errors before damage is dealt

# Physics Constants
const SPEED := (MAX_SPEED*10)/SLIPMOD ## Players horizontal speed value. /!\ Effected by delta
const WALL_JUMP_IMPULSE := Vector2(MAX_SPEED*1.5, JUMP_VELOCITY*1.0) ## The impulse given by wall jumps.
const LEDGE_KICK_IMPULSE_N := Vector2(MAX_SPEED*1.35, JUMP_VELOCITY*0.8) ## The impulse given by ledge kicks.
const LEDGE_KICK_IMPULSE_S := Vector2(MAX_SPEED*1.8, JUMP_VELOCITY*0.8) ## The impulse given by ledge kicks.
const COYOTE_TIME := 0.125 ## The amount of time (in seconds) after leaving the ground in which the player can jump.
const COYOTE_TIME_LK := 0.075 ## The amount of time (in seconds) after leaving the ground in which the player can jump if a ledge kick is possible
const LEDGE_KICK_TIME := 0.175 ## The allowed time (in seconds) in which a ledge kick can be done.
const FALLING_THRESHOLDS := [-250,-50 , 50 , 300, 1000] ## The thresholds separating the falling states.
const CLIMBING_ANIMATION_THRESHOLD := -15 ## The switch point between climbing animations.
const FRICTION_CONST := 0.15/SLIPMOD ## The strength at which friction acts.
const CLIMBING_COEFFICIENT := 0.5/SLIPMOD ## The "friction" experienced when climbing.
const CLIMBING_ADJUSTMENT := 1000.0/SLIPMOD ## The amount the player can adjust the speed when climbing /!\ Effected by delta.
const MAX_AIR_STRIKES := 2 ## The maximum permitted number of airstrikes per jump.
const STRIKE_COOLDOWN_THRESHOLD := 0.25 ## The maximum amount of cool-down required to strike.
const STRIKE_COOLDOWN_COST := 0.25 ## The cost of each strike in terms of cool-down.
const STRIKE_VELOCITY := Vector2(190,-100) ## The impulse given by strikes.

# Variables
#===========================================

# Cat code dependant modifiers

## Used to balance air hovers by boosting jump strength if air hover isnt used. [br]
## Warning: for this project, it is considered best practice for the node
##          controlling jumping to modify this variable.
@export var using_air_hover := true

# Physics variable
var air_time: float = 0.0 ## +ve: seconds in the air, -ve: seconds grounded.
var air_entry: int = 0 ## How the player entered the air
var air_state: int = -1 ## Represents which air state the player is in, view falling thresholds for boundaries.
var first_ascent: bool = false ## True during the players initial ascent.
var animation_state: int = 0 ## Current animation state, view constant for definitions.
var time_walking: float = 0.0 ## The amount of time the player has been walking in their current direction.
var previous_velocity: Vector2 = Vector2(0,0) ## Velocity at the end of the previous frame.
var is_facing_right: bool = true ## True if facing right at the end of the previous tick, note: 0v = right.
var air_strikes: int = 0 ## Number of strikes in current instance of air time.
var strike_cooldown: float = 0.0 ## The amount of cool-down left until next strike.
var wall_time: float = 0.0 ## +ve: seconds on the wall, -ve seconds off the wall.

# Attachments
var current_attachments := [] ## Stores the current attachments.
var strike_attachment_node := preload("res://src/entities/player/attachments/player_attack.tscn")

# Debug
const animation_state_names = ["Idle","Walk","Run","Falling","Climbing"]
const air_entry_state_names = ["N/A","Falling","Ran off","Jumped","Ledge Kick","Wall Jump","Strike"]
var debug_text: String = "DEBUG"

# Signals
#===========================================

signal major_error_occurred(text :String)

# Setup
#===========================================

## Node variables
@onready var debug_text_node = $BasicUI/MarginContainer/PlayerData
@onready var debug_fps_node = $BasicUI/MarginContainer/TempFPS
@onready var sprite_node = $Sprite2D
@onready var animation_player_node = $AnimationPlayer

func _ready() -> void:
	hp = STARTING_HP
	max_hp = MAX_HP
	hp_changed.emit(0, hp)
	max_hp_changed.emit(0, max_hp)
	
	stability = MAX_STABILITY
	max_stability = MAX_STABILITY
	stability_changed.emit(0, stability)
	max_stability_changed.emit(0, max_stability)

# Main Processes
#===========================================

func _physics_process(delta: float) -> void:
	var direction := get_direction_x()
	debug_text = ""
	animation_state = 0

	# Air physics
	calculate_airtime(delta)
	vertical_physics(delta)

	# Handle jump
	calculate_walktime(delta, direction)

	# Ground physics
	running_logic(delta, direction)
	horizontal_physics(delta, direction)

	# Other
	strikes(delta, direction)

	previous_velocity = velocity
	is_facing_right = velocity.x >= 0
	move_and_slide()

	# Animations
	flip_sprite(direction, false)
	calculation_animation_state(direction, delta)
	animation()
	update_debug_text()

	velocity.x *= 1 if (abs(velocity.x) >= delta*5) else 0

	# Debug
	if Input.is_action_just_pressed("debug_damage"):
		damage(1)
	if Input.is_action_just_pressed("debug_heal"):
		heal(1)
	if Input.is_action_just_pressed("debug_destablise"):
		must_be_within_range(2,0,1)
	if Input.is_action_just_pressed("debug_stabalise"):
		increase_stability(1)

# Physics

## Handles vertical physics... pretty much just gravity
func vertical_physics(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta if using_air_hover else get_gravity() * delta * 0.8


## Handles horizontal physics, which is pretty much just friction and air resistance
func horizontal_physics(_delta: float, direction: float) -> void:
	var slipmod_adjustment := 1.0 if abs(direction) > 0 else SLIPMOD*0.75
	velocity.x = lerp(velocity.x, 0.0, FRICTION_CONST * slipmod_adjustment)

# Actions

## Movement logic. [br]
##
## Uses [direction] horizontal input
func running_logic(delta: float, direction: float) -> void:
	#if direction and is_on_floor():
	#	velocity.x += direction * SPEED * delta
	#elif direction:
	#	velocity.x += direction * SPEED * delta * 0.5
	velocity.x += direction * SPEED * delta

## Jumps. [br]
##
## [strength] determines the strength of the jump as a fraction of [JUMP_VELOCITY]
## between -1.0 and 1.0.
# TODO: test
func jump(strength := 1.0) -> void:
	# Checks for errors
	if !(
			must_be_within_range(strength, -1.0, 1.0, "Jump strength") and
			must_be_grounded("Jump")
		):
		return
	# Preceding if none occur
	else:
		air_entry = 3
		air_time = 0
		# Modifies jump strength depending on if air hover is used, this is to prevent punishing
		#	players who do not use air hovers
		velocity.y = JUMP_VELOCITY * strength * 0.95 if using_air_hover else JUMP_VELOCITY * strength * 1.1
		first_ascent = true
		return


func air_hover(delta :float) -> void:
	velocity.y += JUMP_VELOCITY * 2 * delta

## Attack logic, including spawning of the attack nodes. [br]
##
## Contains logic for:
##   attacks
##
## Uses [direction] for velocity impulse
func strikes(delta:float, direction: float) -> void:
	if Input.is_action_just_pressed("secondary_action") and can_strike():
		flip_sprite(direction, true)
		air_strikes += 1
		strike_cooldown += STRIKE_COOLDOWN_COST

		if is_on_floor():
			velocity = STRIKE_VELOCITY * Vector2(direction, 1 + get_direction_y())
			air_entry = 6
			air_time = 0
		else:
			velocity = STRIKE_VELOCITY * Vector2(direction*1.25, 1 + get_direction_y() * 0.75)
		
		current_attachments.append(strike_attachment_node.instantiate())
		current_attachments[-1].set_facing(!sprite_node.flip_h)
		add_child(current_attachments[-1])
	else:
		strike_cooldown = max(0, strike_cooldown - delta)

# Utilities

## Calculates [airtime] in seconds using [delta] assigning the result to [air_time]. [br]
## Also calculates [airstate], [air_entry], [first_ascent] and resetting [air_strikes].
func calculate_airtime(delta: float) -> void:
	if is_on_floor(): # GROUNDED
		air_state = -1
		air_time = minf(air_time, 0) - delta
		first_ascent = false
		air_strikes = 0
		air_entry = 0
	else: # AIRBOUND
		air_state = get_airstate()
		if air_time < 0:
			air_time = 0
			air_entry = 1 if abs(velocity.x) < MAX_SPEED * 0.25 else 2
			# if (abs(velocity.x) < MAX_SPEED) and air_entry != 6:
			# 	air_entry = 1
			# elif air_entry != 6:
			# 	air_entry = 2
		else:
			air_time += delta
	debug_text += "AIRTIME: " + str(round(air_time*100)/100) + "\n"


## Calculates [walk_time] using [delta] and [direction].
func calculate_walktime(delta: float, direction: float) -> void:
	if direction > 0 and is_on_floor(): # WALKING RIGHT
		time_walking = maxf(time_walking,0) + delta
	elif direction < 0 and is_on_floor(): # WALKING LEFT
		time_walking = minf(time_walking,0) - delta
	elif direction == 0: # STATIONARY
		time_walking = 0
	debug_text += "WALKTIME: " + str(round(time_walking*100)/100) + "\n"


## Returns [true] if the player can currently jump
func can_jump() -> bool:
	return air_time <= COYOTE_TIME

## Returns [true] if the cat can attack
func can_strike() -> bool:
	return air_strikes < MAX_AIR_STRIKES and strike_cooldown <= STRIKE_COOLDOWN_THRESHOLD

## Returns [true] if the player is air hovering
func is_air_hovering() -> bool:
	return velocity.y < 0 and air_time > 0 and Input.is_action_pressed("primary_action") #and first_ascent #and (air_entry in [3,4,5])

## Returns [true] if
##   [value_a] and [value_b] are both positive or both negative;
##   [value_a] is 0, when [a_can_be_zero] is [true];
##	 [value_b] is 0, when [b_can_be_zero] is [true] [br]
## Returns [false] if
##   [value_a] and [value_b] are 0, when [both_cant_be_zero] is [true]
func is_same_sign(value_a: float, value_b: float, a_can_be_zero = false,  b_can_be_zero = false, both_cant_be_zero = false) -> bool:
	return (
		(a_can_be_zero and value_a == 0) or
		(b_can_be_zero and value_b == 0) or
		((value_a * value_b) > 0)) and !(both_cant_be_zero and value_a == 0 and value_b == 0)

## Returns the current airstate according to the defined [FALLING_THRESHOLDS]
func get_airstate() -> int:
	for i in range(0,len(FALLING_THRESHOLDS)):
		if velocity.y < FALLING_THRESHOLDS[i]:
			return i
	return len(FALLING_THRESHOLDS)

## Returns the current climbing animation state according to the defined [CLIMBING_THRESHOLDS]
func get_climbing_animation() -> String:
	if velocity.y < CLIMBING_ANIMATION_THRESHOLD:
		return "fast_climb"
	else:
		return "slow_climb"

## Returns horizontal direction
func get_direction_x() -> float:
	return Input.get_axis("left", "right")

## Returns vertical direction
func get_direction_y() -> float:
	return Input.get_axis("down", "up")


## Updates the debug text
func update_debug_text() -> void:
	debug_text += "Y-VEL: " + str(round(velocity.y)) + "\n"
	debug_text += "X-VEL: " + str(round(velocity.x)) + "\n"
	debug_text += "AIR-ENTRY: " + str(air_entry) + "-" + air_entry_state_names[air_entry] + "\n"
	debug_text += "ANIM-STATE: " + str(animation_state) + "-" + animation_state_names[animation_state] + "\n"
	debug_text += "STRIKES: " + str(air_strikes) + "/" + str(MAX_AIR_STRIKES) + " - " + str(round(strike_cooldown*100)/100) + "cd\n"
	debug_text += "J " if can_jump() else ""
	debug_text += "S " if can_strike() else ""
	debug_text_node.text = debug_text
	debug_fps_node.text = str(Engine.get_frames_per_second()) + "fps"

# Aesthetics TODO: check spelling

## Calculates the current [animation_state] assigning the result to the variable. [br]
##
## This function DOES NOT include all animation states
func calculation_animation_state(_direction, delta) -> void:
	if is_on_floor():
		if abs(time_walking) > 1:
			animation_state = 2 # RUNNING
		elif abs(time_walking) > 0:
			animation_state = 1 # WALK
	elif wall_time > 0:
		animation_state = 4 # CLIMBING(ISH)
	elif air_time > delta:
		animation_state = 3 # FALLING


## Flips the sprite to face [direction] [br]
##
## if not [forced] the sprite will only be flipped if grounded
func flip_sprite(direction: float, forced: bool) -> void:
	if is_on_floor() or forced:
		if direction < 0:
			sprite_node.flip_h = true
		elif direction > 0:
			sprite_node.flip_h = false


## Plays (or continues playing) the appropriate anyahmation
func animation() -> void:
	if animation_state == 0:
		animation_player_node.play("idle")
	elif animation_state == 1:
		animation_player_node.play("walk")
	elif animation_state == 2:
		animation_player_node.play("run")
	elif animation_state == 3:
		animation_player_node.stop()
		sprite_node.frame_coords = Vector2i(air_state,3)
	elif animation_state == 4:
		animation_player_node.play(get_climbing_animation())

# Damage

func check_if_dead(cause :String = "Reached 0 HP") -> void:
	if hp <= 0:
		die(cause)

func die(cause :String) -> void:
	print(get_name() + " died due to '" + cause + "'")
	queue_free()

# Validators and errors
#===========================================

## Returns true if value between [min] and [max]. [br]
##   else, returns false, and emits an error. [br]
##
## Produces error "[text] should be between [minimum] and [maximum]."
func must_be_within_range(value, minimum, maximum, text="Value") -> bool:
	if (value >= minimum) and (value <= maximum):
		return true
	else:
		produce_error(text + " should be between " + str(minimum) + " and " + str(maximum) + ".")
		return false 

## Returns true if grounded. [br]
##
## Produces error "Catbot must be grounded to [text]."
func must_be_grounded(text="Value") -> bool:
	if (air_time <= COYOTE_TIME):
		return true
	else:
		produce_error("Catbot must be grounded to " + text)
		return false

# Handles the error message
func produce_error(message :String) -> void:
	decrease_stability(1)
	major_error_occurred.emit("Error: " + message)

# Signals
#===========================================

func _on_killer_area_entered(_area: Area2D) -> void:
	die("Entered " + _area.get_name())

func _on_killer_body_entered(_body: Node2D) -> void:
	die("Entered " + _body.get_name())

func _on_damage_received(_amount :int, _new_value :int) -> void:
	pass # Replace with function body.

func _on_healing_received(_amount: int, _new_value: int) -> void:
	pass # Replace with function body.

func _on_hp_changed(_amount: int, _new_value: int) -> void:
	check_if_dead()
