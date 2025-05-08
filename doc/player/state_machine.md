# Movement state machine - basic

Here are all of the (current) states that the player can be in, for moving. I will definitely need to have multiple state machines later to handle things like combat, healing, etc at the same time. But since I haven't ever done anything with state machines, I want to just implement a basic one to take care of moving around before getting into everything else.
	- Idle
	- Walking
	- Sprinting
	- Jumping
	- Falling
	- Climbing by grabbing the edge of ledge
	- Big climbing (using the axe to go higher than normal climbing)
	- Slowing fall (falling but using the axe to slow, like grabbing the wall and slowing down)
	- Hanging, coming to a deadstop
	- Descending down ropes
	- Swinging from the grapples that are shot out by crossbow

For now, I am only going to worry about these ones
	- Idle
	- Walking
	- Sprinting
	- Jumping
	- Falling
	- Climbing by grabbing the edge of ledge

Here are the states that can be transitioned to from each current state
	- Idle
		- Walking (player starts moving)
		- Sprinting (player starts moving, but is already holding sprint key)
		- Jumping 
		- Falling (for example if something breaks under player, or player falls through a platform like a terraria wooden platform)
	- Walking
		- Idle (player hits a wall or stops moving)
		- Sprinting
		- Jumping
		- Falling
	- Sprinting
		- Idle (player hits a wall, or stops moving)
		- Walking (player runs out of stamina, stops sprinting)
		- Jumping
		- Falling
	- Jumping
		- Idle (don't expect this to ever happen, but if something catches up to the player and now they are standing on top of it)
		- Falling
		- Climbing
	- Falling
		- Idle
		- Walking
		- Sprinting
		- Jumping (jump buffering goes here)
		- Climbing
	- Climbing by grabbing the edge of ledge
		- Idle
		- Walking
		- Sprinting
		- Jumping

How do we stay inside the same state?
	- Inside of the demo code provided by The Shaggy Dev in this [video](https://www.youtube.com/watch?v=bNdFXooM1MQ) ([github link](https://github.com/theshaggydev/the-shaggy-dev-projects/tree/main/projects/godot-4/advanced-state-machines)), there is a snippet of code that is crucial.
	- The code will default return null in the base implementation in the State class, and return null if the state doesn't change as defined in the functions within each State subclass (ex. idle, jump).
	- If the function returns null, then we don't enter into a new state. We only enter a state if the sub State function decides that we are going to

```
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)
```

Here is the default class for each State that is inherited by our movement substates. I am borrowing this from The Shaggy Dev
	- `func enter` is used whenever we enter a new state, and can do things like set a velocity, start a timer, etc
	- `fun process_input` is used to decide if we enter a new state based on input
	- `func process_physics` is used to update the node and enter new states if it makes sense
	- All of the things dealing with `move_component` are created in another script, but the purpose is to keep the parts that decide what the movement direction and such somewhere else. Our states shouldn't figure out that information themselves, since they shouldn't care where it is coming from and only exist to update the state.

```
class_name State
extends Node

@export var animation_name: String
@export var move_speed: float = 400

var parent: CharacterBody2D
var animations: AnimatedSprite2D
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_component

func enter() -> void:
	animations.play(animation_name)

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func get_movement_input() -> float:
	return move_component.get_movement_direction()

func get_jump() -> bool:
	return move_component.wants_jump()
```

Now I will write some pseudocode for each state that we want right now.
```
Idle
function Enter
	set x velocity to 0

function process_input
	if get_movement_input is not 0, then enter the walking state
	if get_movement_input is not 0 and the sprint key is getting pressed, enter the sprinting state
	if the jump key gets pressed, enter the jumping state
	if the player is on a platform (or something that can be fell through) and whichever button gets hit to fall through:
		disable collision for a short period of time
		enter the falling state
	
function process_physics
	if player isnt standing on something enter the fall state


Walking
function enter
	x velocity = get_movement_input
		I want to have acceleration later, but for now this will be fine

function process_input
	if no input, enter idle state
	if sprint key pressed, enter sprinting state
	if jump key pressed, enter jumping state with the current x velocity
		if the player is on a platform (or something that can be fell through) and whichever button gets hit to fall through:
		disable collision for a short period of time
		enter the falling state with the current x velocity

function process_physics
	if player isnt standing on something enter the fall state with current x velocity
	if player hits a wall enter idle state

Sprinting
export var sprint mult
function enter
	x velocity = get_movement_input * sprint mult
		again, acceleration would be nice but will implement this later
function process_input
	if no input enter idle state
	if input and sprint key not pressed, enter walking state
	if jump key pressed enter jump state with current x velocity
	if the player is on a platform (or something that can be fell through) and whichever button gets hit to fall through:
		disable collision for a short period of time
		enter the falling state
	set x velocity like how we do in enter()
function physics_process
	if player hits a wall enter idle state
	if player is not on ground enter falling state

Jumping
export var jump force
export var jump deceleration
function enter
	set y velocity to negative jump force
function process_input
	set x velocity to get_movement_input
	if player hits climb button and is in a spot where they should enter climbing mode
		enter climbing state
function process_physics(delta)
	if player somehow is standing on top of something
		if no input enter idle
		else either enter walking or sprinting
	if player is not holding jump key
		y velocity += delta * jump deceleration
	if y velocity > 0
		enter falling state

Falling
function enter
	set y velocity to 0
function process_input
	set x velocity to get_movement_input
	if player hits climb button and is in a spot where they should enter climbing mode
		enter climbing state
	if player is on top of surface
		if no input enter idle
		if input but no sprint enter walk
		if input and sprint enter sprint
function process_physics(delta)
	add gravity * delta to y velocity to make node fall faster over time

Climbing
Going to do this later because I might want to mess with animation duration based on stamina and don't know how to do that yet, need to read documentation
```