# Control

Before detailing the player character, first a note on controls. All inputs for this game are handled by Godot's built-in input system. This was done to allow controller remapping and because it's good practice to avoid using hardwired inputs.

The player has access to two buttons in code, alongside each direction. This was done partially done as an homage to old game systems such as the NES, which had access to less inputs, but also prevent overwhelming the player with options. By default these two buttons are mapped to the `Z` (or `space`) and `X` key because these keys are easy to find on the keyboard and next to each other. Arrow keys were chosen above `W`, `A`, `S` and `D` for movement because it is more intuitive.

# Player cat / Cat bot

CatBot (class name: `player cat`) is the player character. It uses a [`characterBody2D`](https://docs.godotengine.org/en/4.6/classes/class_characterbody2d.html) as this node class is designed "for physics bodies that are meant to be user-controlled", with the main method of note being `move_and_slide()`, which moves the character body by the `Vector2D` `velocity` whilst handling collision.

As is typical for Godot, CatBot has two main functions:
- `_ready()`, which runs once each time it is instantiated
- `_physics_process(delta)`, which, like `_process(delta)`, is ran every frame, where `_delta` is the duration since the last frame in seconds.

The character was initially built as a more traditional platformer character controlled traditionally, canabalising elements of an existing physics system made by the author. From here, the control mechanisms were exacted out to separate nodes to make this system more modular. The final step was then to create "CatCode", a custom programming system that could replace the modular controllers. To help explain the final system, each of these three stages and the changes between them will be detailed below. But first, I shall describe the main mechanics associated with the character as these remained unchanged throughout the process.

## Mechanics

### Horizontal movement

Horizontal movement is intuitive, one just has to set `velocity.x` to a value to move. For smooth movement, rather than setting `velocity.x` to a constant value, the constant `SPEED*delta` is added to `velocity.x`. For deceleration/friction, this are rather more complicated as a result of friction being non-linear, however this was solved using the function below:

```gd_script
## Handles horizontal physics, which is pretty much just friction and air resistance
func horizontal_physics(_delta: float, direction: float) -> void:
	var slipmod_adjustment := 1.0 if abs(direction) > 0 else SLIPMOD*0.75
	velocity.x = lerp(velocity.x, 0.0, FRICTION_CONST * slipmod_adjustment)
```
Note: direction is a variable representing the horizontal input, -1 being left, 1 being right.

This is the primary system where a second layer of constants were used, in the code referred to as meta-constants, which were used to calculate the values of other constants.

### Jumping and vertical movement

Every frame, when not grounded (determined by `is_on_floor()`, a method provided by the `characterBody2D` class), the a value is added `velocity.y`\*. This represents gravity as is defined globally in the game's internal setting for all physics objects to follow. As well as this, `delta` is added to `air_time` to represent how long the character has been airborne.

Jumping is logically very simple, press button when grounded to gain vertical velocity. However there are two thing that can be done to make jumping feel nicer. Firstly coyote time, described as [find citation explaining this]. This was implemented by replacing the `is_on_floor()` in the `can_jump()` function with `(air_time <= COYOTE_TIME)`.

The other is by adjustment of the jump height by holding down the button. In this project this is called air hovering. #TODO: explain.

\*This value is added because in godot's 2D engine, the y-axis is inverted.

### Swiping



## Stage 1: Tradition

The original system, as stated before, was copied from another project the author developed. This character copied was far more complex than what was required for this project which resulted in some elements getting removed such as wall climbing and jumping. The constants and animations associated with these systems were, however, kept in the script in case these mechanics were reintroduced later.

## Stage 2: Modularization

Stage 2 of the process is where catBot started to match it's final form.

## Stage 3: Cat Code
