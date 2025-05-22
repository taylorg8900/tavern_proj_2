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
	- Wall climb (y input is negative)
	- Wall slide
	- Rope (y input is negative)
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
	- Wall slide
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

Coming back to this the next day, and I've been thinking about how this is all structured. My idea is this:
- Above each 'leaf' on the branch, is at least one 'Manager' that knows about all possible state transitions and what is allowed / not allowed. This is where if/elif statements are placed.
- Each 'leaf' only handles things like physics, and has no concept of switching into other states, that is all handled by the Manager above it.

Also, I think that right now if I structure it like that it really isn't capable of having sub Managers below the PlayerStateManager outside of the following:
- Ground (idle, move)
 - I still think I can have the transitions from Ground to either Jump or Wall climb because we can have the check for those above this sub Managet

I can't have these groupings for at least the following reasons:
- Jump (jump, side jump, reverse side jump)
	- These will have to refer to where they came from to determine which one to enter (ground -> jump, wall climb -> reverse side jump, rope -> side jump)
	- Having these references under a separate Manager than the PlayerStateManager defeats the point and makes things harder to follow, nesting where it is not needed
	- I don't think that Managers need to know about whatever states even exist above them on the hierarchy in the first place, it feels weird
- Wall (wall states + ledge)
	- Certain transitions like (wall climb --('crouch')-> fall) should only apply to wall climb or ledge, and not other wall states such as wall sliding or the future overhang thing
	- Since checking which states can transition into fall should be handled on the same level of the tree, they must all exist on the top level as well

I should probably write pseudocode for determining how we are going to transition
- I could have a big if/elif chain that checks which state is active
	- This would lead to repeated functions calls and bool checks
- I could have a if/elif chain that checks our bools first, then checks each state that can change while under the active bool
	- Again lots of repetition and (if state == state_name) checks, which would lead to kind of the same problem as with the FSM where it is a big spiderweb

I basically need a place where I can define all of the transitions out of a state, instead of in. Let me do that and see if I notice any patterns.

Transitions out of states
- Ground
	- Jump (we press jump, or jump buffer is active)
	- Fall (not on ground anymore)
	- Wall climb (move into wall for long enough)
	- Rope (near rope and want to go up)
- Jump / side jump / reverse side jump
	- Ground (we are on ground)
	- Fall (y velocity is positive)
	- Wall climb (near a wall)
	- Rope (we are near rope and have y input)
- Fall
	- Ground (we are on ground)
	- Jump (coyote time is active)
	- Wall climb (we are near wall, we are below a certain y velocity, state before fall is not wall climb)
	- Wall slide (we are near wall, we are above a certain y velocity, we have x input)
	- Ledge (we are near ledge, we are below a certain y velocity, state before falling is not ledge)
- Wall climb
	- Ground (we are on ground, y input is negative)
	- Fall (not near wall anymore, or we press crouch)
	- Reverse side jump (we press jump, or jump buffer is active)
	- Ledge (we are near ledge, y input is positive)
- Wall slide
	- Ground (we are on ground)
	- Fall (we are not near wall)
	- Wall climb (we are near wall, y velocity is 0)
- Ledge 
	- Jump (we press jump, or jump buffer is active)
	- Fall (we press crouch)
	- Wall climb (y input is negative)
- Rope
	- Ground (on ground, y input is negative)
	- Side jump (press jump, or jump buffer is active)
	- Fall (we press crouch)

So this is way easier to follow and read. There definitely has to be a way I can define this and follow it's structure when we try and select a new state.
- I am going to just try and have a if / elif chain thing going on, probably good enough. I don't think I need to separate out individual sections, that might just make it more complicated
	- Like if I had some other script somewhere to keep track of each transition from each state, why would I not just include that in one spot with all the others? idk

After getting that working, I need to reimplement coyote time and jump buffering. This should all be handled in the PlayerManager, not inside the individual states.
- Reset coyote time when:
	- we go from ground to fall
- Reset jump buffer time when:
	- we are in the air
		- jumps, fall
	- not when it is already active from a previous state (such as going from jumping to falling, we shouldn't reset it if the player already hit jump while in the jump state)

Wow, everything is working again! And it feels better and is way easier to read and change things if I need to. This is great.

# Adding new states and QOL

Here are some of the features that I wanted to include back before I got working on this version of the state machine a few days ago:
- Corner correction (when you jump into a ceiling and there is an open space that you get moved to automatically)
- Ledge magnetism (when you jump onto a ledge but miss just barely, teleport over a little bit)
- Make walking down slopes not bouncy
- Transitions
	- (wall slide -> wall overhang hang) instead of (wall slide -> fall) if our velocity is under a certain threshold
	- (wall climb -> wall hang) if we climb down to an overhang
	- Transition (ground -> ledge climb down)
		- Maybe if we are holding 'down' and press 'jump' 

Corner correction
- [this video](https://www.youtube.com/watch?v=tW-Nxbxg5qs) has a way of implementing corner correction that I did not consider and seems better than what i had in mind
	- Here is what it does:
		1. It will check to see if we will hit a ceiling on the next physics process using delta
		2. If we do, it will check to the left and right a certain amount of pixels and see if we would still hit the ceiling
		3. If we don't still hit the ceiling on the left / right, move the player that many pixels over
- My idea was to use raycasts, which I am going to actually try and implement. There are two reasons for this:
	1. I can make this work better with raycasts anyways
	2. The solution above doesn't work properly because test_move detects collisions with an extra margin
		- If we were in a wall climb, and fell down, and then jumped back up, we *would* have pixel perfect collision. But test_move checks an additional .01 pixels or something so it freaks out 
		- For the same reason, even if we move the player over and round their x coordinate so it is now pixel perfect and should work, test_move will prevent the player from actually travelling upwards and will lock them in place pretty much

I am going to consider the following
- Corner correction should only occur in the direction that you are travelling in, but if you are not moving it is fine to check both directions
	- Having a ceiling to the left while you are moving to the left will snap the player backwards and it is kind of jarring, as an example

pseudocode
```
have a raycast 2d shoot backwards from in front of the player with the same width as our hitbox
if it is hitting a ceiling, find out where the global collision point was at
subtract the collision point from our raycast's global position
if the absolute value is less than our defined max, return the float
	the float = raycast global pos - collision global pos
add the float to our player position
```

An issue that I am facing is that if the object we are detecting a collision on is different than the one the raycast2d is inside, it will still report a collision.
This means if the player jumps into a ceiling nowhere near a corner, between two blocks, it will still try to apply corner correction. I could probably fix this by adding another raycast2d that checks if the first one is inside of anything.

I have it working for both directions, but I want it to also work in either direction if the player is not moving.
- I have this implemented with just another set of raycasts
