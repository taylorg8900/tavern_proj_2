
What would my PlayerManager class look like?
```
inherits StateManagerCore

get reference to the following
	- all raycasts
	- the jump buffer timer
	- a coyote time timer
		- The reason for this being a node now is that I want to be able to set it's time within states if needed, which we can do from here since they wouldn't inherit from PlayerManager


@export jump buffer time amount : float
@export coyote time amount : float

input : Vector2

on_ground : bool
in_air : bool
near_ledge : bool
near_wall : bool
near_rope : bool

ropes : array

_ready()
	call SetUpStates() from our StateManagerCore
	connect rope signals with our rope functions
	set up our starting state with state_machine.Set()

_physics_process(delta: float)
	check is_complete
	else if other stuff
	call Do() on our current state

_process(delta: float)
	update input with GetInput()

GetInput():
	just figure out what x and y should be for input based off of wasd, left is negative and down is negative
	for example left and up being pressed at same time is Vector2(-1, 1) since our x component is -1 and y component is +1

OnGround() -> bool:
	if we are on ground return true

InAir() -> bool:
	return if we are in the air

NearLedge() -> bool:
	return if we are near ledge, use the little raycasts and all that 

NearWall() -> bool:
	return if we are near a wall duh

NearRope() -> bool:
	return if we are near a rope

SnapToLedge() -> void:
	set player position to ledge 

GetDirection() -> void:
	returns -1 if our animatedsprite2d is facing left, +1 if facing right

FlipDirection() -> void:
	flips the animation and raycasts for our character

ResetCoyoteTime() -> void:
	resets our timer

ResetJumpBuffer() -> void:
	resets our jump buffer timer

EnterRope(node_entered, rope, x_pos)
	copy this from where it currently is inside State.gd

ExitRope(node_entered, rope, x_pos)
	copy this from where it is in State.gd
```
