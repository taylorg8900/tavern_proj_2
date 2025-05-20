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

Transitions into states (will not include requirements inside of individual transitions, since it is implied)
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
	- Reverse side jump
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
		- We are in air
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
	- Ledge (y input is negative)
- Wall slide
	- Requirements for transitioning into this state
		- We are near a wall
		- X input is towards the wall
		- Y velocity is above a certain amount
	- Fall
- Ledge
	- Requirements for transitions into this state
		- We are near a ledge
	- Jump (state before jumping is not ledge)
	- Side jump
	- Reverse side jump
	- Fall (we are below a certain positive y velocity, state before falling is not ledge)
	- Wall climb (y input is positive)
- Rope
	- Requirements for transitioning into this state
		- We are near a rope
		- we have y input
	- Idle
	- Move
	- Jump
	- Side jump
	- Reverse side jump
	- Fall

What I am noticing is that I need some way of determining from within managers that if we didn't switch into any of their substates, we can fall back to the first part of the branch where we are able to switch into a state.

For example, look at this:
1. We are in a fall state, next to a wall, with a very high velocity, and no x input
2. We 'enter' the 'Wall' state manager from our PlayerStateManager, which is reponsible for various wall substates (such as wall climb, wall slide) because our bool `near_wall` was true
3. We go through some function to select a substate within 'Wall', but it does not return us anything because we did not meet any conditions :(
4. We did not get a new state from the 'Wall' state manager
5. Since the furthest we could go on the branch was 'Fall', we execute the physics instructions it has within on our PlayerStateManager
	- In this case, our 'branch' stops inside the PlayerStateManager and is only one layer deep

What kind of a function do we need that can do the following?
- go look inside of a manager (if the condition for looking inside passes), and see if it returns us a state
- enter the returned state if it is not null and if it is different than what we already have

Where could this go wrong?
- What if we have multiple bools which are true, and we have conflicts for determining which state we should enter into?
	- in air
	- near wall
	- `wall climb -> in air -> crouch pressed -> fall`
	- `fall -> near wall -> moving too slowing -> wall climb`
	- We could just make sure the new state can't be the previous state?
		- This would mess up the `ledge --(y input negative)-> wall climb --(y input positive)-> ledge` allowed transition 
	- Other games solve this by offsetting the player when this specific transition happens, so they don't immediately transition back

We can only have one leaf node active at a time
We must always have one leaf node active 
