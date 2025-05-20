I need a place where I can think through when we should switch between certain states. Even though there is less repeated code than with the starter state machine where each state is responsible for deciding whether to switch, it is kind of confusing to keep track up and down the tree.

Here are the current states I want to refactor to work with the hierarchical state machine:

PlayerManager
- Ground
	- Idle
	- Move
- Jump
- Fall
- Wall
	- Wall climb
	- Wall slide
	- Reverse side jump
- Rope 
	- Rope climb
	- Side jump
- Ledge
	- Ledge hang

And here is my idea of how this would work with future states:

PlayerManager
Here is my current thought of a state diagram:
PlayerManager
- Ground
	- Idle
	- Move
	- (future) Crouch (holding ctrl)
	- (future) Dodge roll
	- (future) Ledge descend
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
	- (future) Wall overhang hang
- Rope climb
	- Side jump

What am I getting stuck on?

Here is a situation I am trying to avoid:
1. We are in a ledge hang
2. We press jump, and enter a jump
3. On the next physics process, we check to see if we are near a ledge -> we immediately enter a ledge hang

Another situation I want to be able to happen:
1. We are in a ledge hang
2. We want to enter a climb state by pressing down
3. For however long we are in the climb state, even though we are right next to the ledge, we will not enter it unless we go down and then come back up first

I am trying to keep states from transitioning when they shouldn't from within the substate manager, and not the parent manager

How should I handle that situation?
1. We are in a ledge hang, and want to jump
	- I want to enter the actual 'jump' state from within the parent manager
	- I don't want to immediately re enter the ledge hang on the next physics process
2. We enter a jump state
3. We only reenter a ledge hang from the jump state if it's parent is not a ledge hang

I almost feel like I need to step back and analyze exactly what structure I actually need for all of this. 
Because I am trying to get it to fit in with how AdamCYounis had it in his video, but I feel like that structure is really suited for just AI.
I will list out all possible state transitions and see if I notice some kind of pattern - I might need a different structure for this.

All current bools
- on ground
- in air
- near wall
- near ledge
- near rope

All current states
- Idle
- Move
- Jump
- Side jump
- Reverse side jump
- Fall
- Wall climb
- Wall slide
- Ledge 
- Rope

Transitions into states (will not include requirements inside of how we got into the state, since it is implied)
- Idle
	- Requirements for transitioning into this state
		- We are on ground
		- No velocity
	- Move (we stop moving by applying deceleration)
	- Jump
	- Side jump
	- Reverse side jump
	- Fall
	- Wall climb (state before wall climb was not idle)
	- Rope (state before rope was not idle)
- Move
	- Requirements for transitioning into this state
		- We are on ground
		- We have x input
	- Idle
	- Jump
	- Side jump
	- Fall
	- Wall climb
	- Rope
- Jump
	- Requirements for transitioning into this state
		- We press jump
	- Idle (jump buffer is active)
	- Move (jump buffer is active)
	- Fall (coyote time is active)
	- Ledge (jump buffer is active)
- Side jump
	- Requirements for transitioning into this state
		- We press jump
	- Rope (jump buffer is active)
- Reverse side jump
	- Requirements for transitioning into this state
		- We press jump
	- Wall climb (jump buffer is active)
- Fall
	 - Requirements for transitioning into this state
		- We are in air / not on ground
	- Idle
	- Move
	- Jump (y velocity is positive)
	- Side jump (y velocity is positive)
	- Reverse side jump (y velocity is positive)
	- Wall climb (we press 'crouch')
	- Ledge (we press 'crouch')
	- Rope (we press 'crouch')
- Wall climb
	- Requirements for transitioning into this state
		- We are near a wall
	- Move (we move into the wall long enough)
	- Jump
	- Side jump
	- Reverse side jump
	- Fall (we are below a certain positive y velocity)
	- Wall slide (y velocity = 0)
	