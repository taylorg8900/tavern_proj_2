
What would my PlayerManager class look like?
```
inherits StateManagerCore

get reference to the following
	- all raycasts
	- CollisionShape2D
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
	check all of our bools up there in here
	call Do() on our current state

_process(delta: float)
	update input with GetInput()
	check our jump buffer or coyote time in here

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


Here is my current thought of a state diagram:
- PlayerManager
	- Ground
		- Idle
		- Move
		- (future) Dodge roll
		- (future) Combat
			- (future) Aim Runestone
			- (future) Aim crossbow
			- (future) Block
		- (future) Ledge descend
	- Air
		- Jump
		- Fall
	- Ledge 
		- Ledge hang
		- (future) Ledge ascend
	- Wall
		- Wall climb
			- Look right / Look left
			- Reverse side jump
		- Wall slide
		- (future) Wall hang
	- Rope climb
		- Side jump


Let me try and figure out what this would look like for our starter set of states
- PlayerManager
	- Ground
		- Idle
		- Move
	- Jump
	- Fall
	- Wall
		- Wall climb
		- Wall slide
		- (future) wall hang
	- Rope climb

PlayerManager
```
func select state:
	if on_ground
		if jump buffer
			Set(jump state)
		Set(ground state)
	if get_jump
		if state == fall
			if coyote timer
				Set(jump state)
		if state == ground
			Set(jump)
	if near_wall
		if state == ground
			if wall timer < 0
				Set(wall state)
		else
			if input != 0 or y velocity < 0
				Set(wall state)
	if near_rope and input.y != 0
		Set(rope state)
	
		
		
	if state == ground
		if move into wall timer < 0
			Set(wall state)
	
```
