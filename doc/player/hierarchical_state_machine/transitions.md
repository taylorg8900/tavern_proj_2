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
