
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
- Ground
	- Idle
	- Move
- Air
	- Jump
	- Fall

```
PlayerManager stuff

ground state
air state

_physics_process(delta: float)
	update all of our bools
	if state_machine.state == ground
		if in air
			Set(air, true)
	elif state_machine.state == air
		if on ground
			Set(ground, true)
	call DoPhysicsBranch(delta) on our current state

_process(delta: float)
	update input with GetInput()
	call DoBranch(delta) on our current state
```

```
Ground State stuff

idle state : State
move state : State

func Enter():
	do nothing here actually
	maybe set y velocity to 0 (core.body.velocity.y = 0)

func DoPhysics(delta : float) -> void:
	pass

func Do(delta : float) -> void:
	if we have x input
		Set(move, true)
	else
		Set(idle, true)
```
