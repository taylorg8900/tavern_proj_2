# Movement state machine - basic


Here are all of the (current) states that the player can be in, for moving. I will definitely need to have multiple state machines later to handle things like combat, healing, etc at the same time. But since I haven't ever done anything with state machines, I want to just implement a basic one to take care of moving around before getting into everything else.
- Idle
- Walking
- Sprinting
- Jumping
- Falling
- Ledge grabbing
- Big ledge grabbing (using the axe to go higher)
- Wall sliding (falling but using the axe to slow, like grabbing the wall and going slower)
- Wall hanging
- Rope descent 
- Grapple swinging

For now, I am only going to worry about these ones
- Idle
- Walking
- Sprinting
- Jumping
- Falling

Here are the states that can be transitioned to from each current state
- Idle
	- Walking (player inputs movement)
	- Sprinting (player starts moving, but is already holding sprint key)
	- Jumping (player inputs jump)
	- Falling (player is no longer on ground)
- Walking
	- Idle (player hits a wall or is no longer providing movement input)
	- Sprinting (player inputs sprint key)
	- Jumping (player inputs jump key)
	- Falling (player is no longer on ground)
- Sprinting
	- Idle (player hits a wall, or stops moving)
	- Walking (player runs out of stamina, stops sprinting)
	- Jumping (player inputs jump key)
	- Falling (player is no longer on ground)
- Jumping
	- Idle (don't expect this to ever happen, but if something catches up to the player and now they are standing on top of it)
	- Falling (player y velocity is greater than 0)
	- Climbing (player is within range to climb and inputs jump key)
- Falling
	- Idle (player is on ground and is not inputting movement)
	- Walking (player is on ground and is inputting movement)
	- Sprinting (player is on ground and is inputting movement and sprint key)
	- Jumping (player is on ground and inputs jump) (jump buffering goes here)
	- Climbing (player is within range to climb and inputs jump key)


I am going to be using the implementation that The Shaggy Dev uses in his [youtube video](https://www.youtube.com/watch?v=bNdFXooM1MQ&list=PLaiU9HSaKMWtmAIR345HGIz_ijQiyr3kH&index=7), and when I am comfortable with how it works I will start doing my own thing.

How does it work?
- Each state inherits a class named `State` that has methods which can return other states, but by default will return `null`.
- The state machine will only switch into another state and call it's `enter` function when it receives a return value that is *not* `null`.
- In this way, we will stay inside of a state every frame until it is decided that it should switch into something else in either the `process_input` or `process_physics` function.
- We can have special behavior inside of the `enter` function like setting a velocity to a certain value, and state specific values (which are exported to the Inspector for easy modification)

After implementing the sprint state, I actually realise it is pretty annoying to have to physically press the shift if I want to sprint, and having there even be two different states for moving (walking and sprinting). If originally I wanted acceleration, why wouldn't I just have one state called "move" that implements that? Besides, there are tons of games that are 2D which don't have sprinting functionality (among us, terraria, hollow knight, dome keeper, rounds, drg survivor) and instead can delegate that button to some extra function. In all reality I will likely end up having that button as my shielding key, or diving, etc.

### Creating acceleration for the `move` state

How do we implement acceleration?
- Delta means 'per second' in the process functions
- We can define the number of seconds it should take to reach our max velocity
- Our acceleration will be the max velocity divided by number of seconds it takes to reach it, multiplied by delta

How do we implement deceleration?
- We need to slow down the player by an amount each process, if the player has any x velocity
- When the x velocity of the parent is 0, then we switch to the idle state, not when there is no input

```
func process_physics
	if movement input
		increase x velocity by acceleration value * delta
		limit x velocity so it does not exceed max move speed
	else if no movement input, but still x velocity
		decrease x velocity by deceleration value * delta
	else
		idle state
```

# Updating the state machine with more states

Since I updated 'walk' to just 'move' after getting rid of sprinting, I will now refer to it as such.

Here are the next states that I want to work on:
- Ledge grabbing
- Wall sliding

Ledge grabbing is pretty self explanatory. I don't think I want the player to automatically climb up the ledge, because I could imagine that there is a reason that the player would want to wait before doing so. I want it to transition to either 'ledge climbing', or 'dropping'. I could also use the 'dropping' state later, with wall hanging so it seems like that is the way to go. For wall sliding, I want the player to decelerate until they come to a stop; since I can't really have wall sliding without hanging, here is the updated states I actually need right now, along with what they can transition to.
- Ledge grabbing
	- Ledge climbing
	- Dropping
- Ledge climbing
	- Idle
	- Moving
	- Jumping
- Wall sliding
	- Wall hanging
	- Dropping
- Wall hanging
	- Dropping
- Dropping
	- Idle
	- Moving
	- Jumping
	- Stun and take damage (later)

To expand on what 'dropping' is, I want the player to not be able to perform an unlimited amount of wall hangs or ledge grabs. It basically puts the player into a fall state, but they are unable to transition into another wall slide, wall hang, or ledge grab.

Also, we need to add these states to our previous states. Here's where they will fit in:
- Jumping
	- Ledge grabbing
- Falling
	- Ledge grabbing (if y velocity is too high, don't let the player do this!)
	- Wall sliding

There are some things I need to figure out before I go about actually creating these:
- Do I have the player automatically ledge grab if they are inputting movement into the ledge?
	- This is the approach I will take right now, since not doing so is like having the sprinting state above, which was really annoying.
- How do I detect if the player is facing towards a wall / ledge?
	- I think I need raycasts (if that is what they are called). I need to read the documentation or find out if there is a node I can use for this.
		- It appears that using `raycast.is_colliding()` will work
		- After googling, you can apparently rotate the raycast. I will try using `set_rotation_degrees(value)` for this
		- I need two raycasts. If the top one is not detecting anything, but the bottom one is, then we are next to a ledge

### wall sliding

I need to approach this differently than I did with the move state's acceleration and deceleration. Since the player can enter a wall slide state at various speeds, I can't have a fixed amount of time it takes for them to slow down; otherwise, a player falling at mach 1 and barely falling would take the exact same time to slow down, which doesn't make sense. Instead, I need a value by which to slow the descent by every second. I think having a number specifically for how much to slow the y velocity should do the trick, but I also want it to be intuitive. I think having a 'tile slow per second' would make sense. How does the y velocity of the player correlate with the size of tiles in Godot in the first place though?
- The velocity of the CharacterBody2D is in pixels per second: That means a speed of 16 means it would only cover one 16x16 sized tile per second. I tested this and it seems to hold up.

```
deceleration = tile size * how many tiles to slow down per second by

func physics_process()
	slow down y velocity by deceleration amount * delta
	if y velocity == 0
		enter wall hang state
	if movement input not equal to direction we are facing
		flip animations and raycasts
		enter drop state
```

At this point I am also realizing that the default gravity value is way too high. I am going to watch that [video](https://www.youtube.com/watch?v=hG9SzQxaCm8) about making custom jumps, and maybe it will give me insight into what values for gravity would feel good.
- I watched it, and watched this [other video](https://www.youtube.com/watch?v=IOe1aGY6hXA) that pretty much just sums up the important parts with some code I can use as well.
	- It turns out I can't really rely on this because I have two separate states (jumping, and falling) and want to implement variable jump height too.

What if there was another state for the player to anticipate wall sliding? It is pretty difficult to time this perfectly, just like why I will implement jump buffering soon.

### upgrading the jump and fall state

Here are the things I need:
- A default jump height
- Amount of time it takes to reach the jump height
- A multiplier for how fast the standard gravity increases by if the player is not holding the jump button anymore
- Something to keep track of the player letting go of the jump key; if they do this, then they can't go back to the normal gravity

Here are the things I need to upgrade the fall state to have the same faster gravity as the jump state's variable gravity value:
- First option
	- The default jump height value
	- The amount of time it takes to reach the ground from said value
- Second option
	- The default jump height value
	- The time it takes to reach the jump height
	- A multiplier for how fast the standard gravity increases

Since I am going to be reusing these values between multiple states, I am actually going to implement them in the State class with the ability to change them later with `@export`. I will want to have other states for things like diving, anticipating a wall slide, etc so this makes sense.
- I found out that if you use the `@onready` thing in the superclass, it will work with the values that you give it in the subclass. Not sure how that works but it is really useful

Also, I realized that it would probably be good to have a terminal velocity AKA a speed that the player can't fall faster than. I'm going to add that as well.

Since having all of these variables inside of the state class was filling up the Inspector, I made another class named AirState that inherits from State, to be used by any class which is in the air.

# Ledge climbing, wall hanging, and wall climbing

Why did I not consider that we should let the player climb up walls??? It totally makes sense, our guy is a little dwarf. Of course he could climb. We are going to be in caves and stuff, with rocks. I really want to implement that now.

I also still don't have a ledge climbing mechanic in place, so I think I will get all three of those now.

### Entering climbing state

Something I am thinking about is what if we made it so the wall slide thing was automatic? This would save the trouble of pressing a key to enter it, and in future versions of the game where the player is moving around rapidly, I don't think it would be fun to have to think about pressing a key each time you were trying to slow down while getting the fuck away from a monster. It makes sense to delegate that mental effort towards something like exiting the wall slide instead.
- I changed one line of code and this feels amazing, much better and slick

For climbing, I want it to happen when the player is pressing diagonally, not just to the side and not just up either.
- I also want to try if the player is pressing the jump key

I think we should enter the climbing state from these states
- Move
	- If the player keeps walking into the wall for a certain amount of time (entering the state instantly would be annoying)
- Wall hang
	- I think I can get away with not having it be entered from both the jump and wall hang state, so this *might* be good enough. I can always change it later.
		- It turns out I am changing this lol

I do want some kind of stamina that the player has when they are either wall hanging or wall climbing; this way, the player can't just stay on the wall forever. I kind of have to share the value between the two in the first place, because if the player could enter a climbing state from the wall hang (which would have stamina), then they could stay on the wall forever and that is no good.

### State transitions

Updated transitions from each state
- Move
	- Wall climb
- Jump 
	- Wall climb
- Ledge hang
- Wall hang
	- Drop
	- Wall climb
- Wall climb
	- Drop
	- Ledge hang

### implentation

pseudocode for wall climbing
```
export var climbing speed

func process phys
	if player holding diagonally
		y velocity = climbing speed, prob do some move towards stuff here just cuz
	else
		y velocity = 0
	
	move and slide (dunno if i need this tbh)
	
	if near ledge
		enter ledge hang state
	if movement input not equal to direction we are facing
		enter drop state
```

# Improving the ledge climb mechanic

Before going to sleep last night, I saw [this video about ledge climbing](https://www.youtube.com/watch?v=1v514Q_QInc&list=LL&index=1) that uses a collision shape for the player to hang onto ledges. I like this because it is pixel perfect, and I have noticed that for some reason using the raycasts can lead to inconsistent positioning while near ledges. Sometimes the player is a little higher or lower. I'm not sure if I like the idea of having the player transition directly into the jump state, but I will save that for later. If I stick with my original idea of having an animation of climbing up the ledge, then I will still need pixel perfect positioning anyways, and the raycasts aren't doing it tbh

I didn't know how to implement the collisionshape while moving upwards, so I thought that changing how we enter the ledge grab state with the raycasts could be made consistent if I changed how that worked. It still doesn't work, and subpixel movement happens, which we don't want.

I think I could try to figure out a way to snap the player to the right position? Let me read the documentation
- RayCast2D: get_collider() to figure out what we are intersecting
- RayCast2D: get_collision_point() - "Returns the collision point at which the ray intersects the closest object, in the global coordinate system."
	- If the top ray was facing straight down, this would probably work for snapping the character to a certain y position
- ShapeCast2D: get_closest_collision_safe_fraction() - seems like a complicated version of get_collision_point from RayCast2D, but could be used
- ShapeCast2D: get_collision_point()

I think I will try this out:
- Have 4 raycasts
	- One above and to the side of the character facing down, used to calculate which position we will snap to
		- This might benefit from being a shapecast2d, because then we don't have to rotate it when we flip our animations / direction
	- One above the character facing out, to detect if there is open space above diagonally
	- One next to the character facing sideways, to detect walls
	- One below the character facing down, to detect if we are not above a floor

pseudocode
```
when we detect that we are near a ledge
use the shapecast2d to find out the global y position of where the ledge is using get_collision_point()
find the offset between our shapecast2d and the collision point
our character position -= offset
```

updated pseudocode after messing with things
```
when we detect that we are near a ledge
use a raycast pointing down to find the y position of whatever we intersect
use the wall raycast to find the x position of the wall where we intersect
find the offset between these and wherever our hand is
	I used the TopRayCast for this, because it is placed where the hand will be
add the offset to our character
```

After I got it working, a bug that got introduced is that checking for jump input using `is_input_just_pressed()` will not really work since it updates each frame, so it treats it like `is_input_pressed()` instead. This means if we enter a ledge hang state and are holding spacebar, we will instantly jump. I don't know how to fix this yet.

Also, none of this would work for platforms which move up and down, so in the future I will need to use the collisionshape2d and only activate it in the ledge hang state. But that's pretty easy and I'm not that worried about it yet.

As a side note, I think it would be more fun to let the player enter the fall state instead of the drop state for all of the wall states. It would be fun to chain wall slides together, and if you got unlucky and had a wall hang like a hundred feet in the air and couldn't avoid dying, that would really fucking suck. I will repurpose the drop state to be a copy of the fall state, but we can't enter a ledge hang again. This is what I am doing for the ledge climb state for now, where it is just a copy of the jump state but we can't enter another wall hang. I will definitely need to change both of these in the future, since I don't like copy and pasting stuff like this.

# Wall jumping

I don't really have a solid reason for wanting to implement this other than I think it would be really fun, and it is kind of dissapointing to just drop like a rock when I change directions while climbing. Also, what if in the future I have environmental dangers like falling rocks that you need to dodge?

I don't want this to have the same physics as normal jumping, I want it to be a lot more side to side and not so much up and down (if that makes sense). Also, if we transition directly into a normal 'fall' state, we won't be able to automatically do all of the cool wall stuff like wall slide since we can't in the fall state. We will need to handle both the upwards and downwards y velocity logic in here, instead of separating them.

States that can transition into the wall jump
- wall hang
- wall climb

# Rope climbing and descent

Wow, this is the last one I planned on making! I don't really know what I will implement after this. Crazy that I actually made it this far already.

I want this to behave the same as the wall climbing and wall sliding, but the climbing part is noticeably faster, and the descent is snappier / more controllable. I also want the player to be able to change directions while on the rope before deciding to jump off.

### creating ropes

(yo how the fuck do I do this???)

My first thought was to create tiles, but I asked chatGPT and it started yapping about Area2Dnodes. I figure in the future when I get into procedural generation, I won't be able to create everything out of tiles anyway so it's not like I need the ropes to be tiles. What can we do with the Area2D node? I haven't used them before.
- Area2D.body_entered() - tells you if something is inside it, uses signals (which I don't know how to use yet)
	- Will need this so player can attach to one
- Sprite2D - need for the texture part

I am going to handle creating the ropes in another section of this documentation, and only worry about the state itself here.

After figuring out how to make ropes, here is what the state should be able to do:
- Move up and down the rope at speeds like specified above
	- Moving up should be handled by either jumping, or holding up
- Be able to jump off the rope, but only if we are holding a direction sideways and also want to jump
- Exitting the rope state should put us in wall jump mode, instead of regular jump mode.

Transitions between states
- States that transition into the rope
	- Idle
	- Move
	- Fall
		- Will probably need another state for this, like the wall sliding because I don't want the character's velocity to immediately be 0
	- Wall jump
	- Ledge fall
- Rope, into other states
	- Idle (if we hit the ground)
	- Move (if we hit ground, but our movement input is not 0)
	- Fall (if we descend and the rope runs out of rope)
	- Wall jump (standard jump for getting off rope)

# QOL

Here are a bunch of other things that I need to implement now that all of the states I set out to make are working (crazy that I've come this far)
- Coyote time
- Jump buffering (when you hit the jump button before you actually hit the ground)
- Corner correction (moves the player a little horizontally when they are going to just barely hit ceiling, avoids pixel perfect collisions which are annoying)
- Ledge magnetism (moves the player over a few pixels if they just barely would have missed otherwise)

### Coyote time

Coyote time definitely seems like the easiest one, and it's about time that I learned how to use timers. I don't know if I actually need a timer, since the coyote time doesn't persist between states... I think.
- Coyote time only happens while you are falling, so do I even need a timer?

While implementing coyote time, it turns out you can just spam jump since the jump and fall states can now transition to each other, allowing you to fly. I am going to fix this by having another variable to keep track of if we have jumped, and reset it when we exit the falling states.
- Since inheritance means the 
- Bro you can use static variables and functions in godot what the fuck wait a minute
	- I am going to use this to keep the variable shared between classes (im also too hungry to remember why this works but i know it does)
- Set `has_jumped` to true when:
	- We enter a any jumping state
- Set `has_jumped` to false when:
	- We enter any state that doesn't inherit from AirState, AKA anytime we are touching a wall or floor or whatever

I ended up changing these to functions that reset coyote time so it is more readable, and better named variable names.
- In the exit function of states that could transition into a fall, where it makes sense I reset the coyote timer
	- For example I would choose to have this exempt from the wall slide state, since I don't want the player to be able to jump right after, which they would be able to do normally in the fall state if we got there from the move state instead
- In the enter functions of other states, such as jump, I set the coyote timer to 0 
	- This is because we don't actually reduce the coyote timer automatically unless we call the function that does that, and it is more efficient to just set the variable to 0

### Jump buffering

Jump buffering also seems easy, but I think I do actually need a timer for this since there are some cases where having a variable changed by delta within just one state probably wouldn't work (falling -> ledge grab -> ledge climb, or jump -> rope -> rope jump)
- I could maybe just have this as another static variable that gets reset during the `enter()` function of states, and incorporate it into the `get_jump()` function somehow
- I could check to see if the jump buffer is active anytime we would also check for get_jump, and if it is active then we just transition like how we would normally

I actually want to use a timer, since it is different than using the coyote timer variable - since we don't start taking away from the jump buffer's float value until we trigger a jump input, we would end up needing some kind of tracker variable inside of our states just to know if we are allowed to start taking away delta time in our process_physics. I could definitely do that, but I also want to see if I can figure out the timer thing.

What do I need from the timer?
- A way to reset the timer just like we have in the exit functions of our states
	- Having the oneshot property turned off and having it automatically reset might actually be really useful, though it might mean that we can spam jumps in mid air and constantly trigger it so idk
	- calling stop() is apparently how you do this, which i guess can make sense since pausing would take care of pausing it yo im tired brother
- A way to see how much time is left, and if is greater than 0
	- get_time_left() would work
- A way to start the timer
	- start()

Using a timer might be a problem in the future. This line of code is in the documentation: "An unstable framerate may cause the timer to end inconsistently, which is especially noticeable if the wait time is lower than roughly 0.05 seconds. For very short timers, it is recommended to write your own code instead of using a Timer node."

I have implemented it, but just to make sure I should identify in which states we want to use the jump buffer timer, and which states we want to reset it in. Then I will double check my implementation so it is correct.

I am also going to reidentify all of the states we can transition into and from, just to make sure everything looks good right now. This might be too much but whatever, being thorough is part of my process.
- Idle
	- Reset coyote time for these cases
		- (Idle -> Fall -> Jump)
	- States
		- Move (if movement input)
		- Jump (if jump input, or jump buffer has time left)
		- Fall (if we are somehow not on the ground anymore)
		- Rope (if we are near a rope and we press 'up')
- Move
	- Reset coyote time for these cases
		- (move -> fall -> jump)
	- States
		- Idle (if our x velocity is 0, instead of checking for movement input because we need to consider deceleration)
		- Jump (if jump input, or jump buffer has time left)
		- Fall (if we are not on ground anymore)
		- Rope (if we are near a rope and press 'up')
		- Wall climb (if we try to move into the wall for a certain amount of time)
- Jump
	- Reset jump buffer, in the unlikely case that a platform comes up to meet us and we want to jump again
	- Reset jump buffer, so that the timer will be active in these cases 
		- (jump -> idle -> jump)
		- (jump -> move -> jump)
		- (jump -> wall hang -> wall jump)
		- (jump -> wall climb -> wall jump)
		- (jump -> ledge hang -> ledge climb)
		- (jump -> rope -> rope jump)
	- States
		- Idle (if a platform comes up to meet us)
		- Move (if a platform comes up to meet us and we have movement input)
		- Fall (if our y velocity is > 0)
		- Rope (if we are near a rope and want to go up or down)
		- Wall hang (if we are near a wall, input into it, and our y velocity is exactly 0)
		- wall climb (if we are near a wall, input into it, and our y velocity is < 0)
		- ledge hang (if we are near a ledge)
- Fall
	- Reset jump buffer timer for these cases
		- (fall -> idle -> jump)
		- (fall -> move -> jump)
		- (fall -> rope -> rope jump)
		- (fall -> ledge hang -> ledge climb)
	- States
		- Idle (if we are on ground and our movement input is 0, instead of checking for x velocity since that would cause animations to play in the future which would look janky)
		- Move (if we are on ground and have movement input)
		- Jump (if our coyote timer has time left)
		- Rope (if we are near rope and press either up or down)
		- Wall slide (if we are near wall and input into it)
		- Ledge hang (if we are near ledge)
- Rope
	- Reset coyote time for these cases
		- (rope -> rope fall -> rope jump)
			- I will need to research some way of keeping track of which state I have been in previously for this to even work properly, or create a new state called 'rope fall', which is the quick and dirty option for right now which I might do)
	- States
		- Idle (if we are on ground and have no movement input)
		- Move (if we are on ground and have movement input)
		- Rope jump (if we want to jump, or if our jump buffer timer has time left)
		- Rope fall (if we fall off rope)
- Rope jump
	- Misc
		- I would like to disable movement during the upwards part of this, just like with wall jumping (handled below)
	- Reset jump buffer for these cases
		- (rope jump -> idle -> jump)
		- (rope jump -> move -> jump)
			- like if a platform came up to meet us
		- (rope jump -> rope -> rope jump)
		- (rope jump -> wall climb -> wall jump)
		- (rope jump -> wall hang -> wall jump)
		- (rope jump -> ledge hang -> ledge climb)
	- States
		- Idle (if a platform came up to meet us and we have no movement input)
		- Move (if a platform came up to meet us and we have movement input)
		- Fall (if our y velocity > 0)
		- Rope (if we are near rope and want to go up or down)
		- Wall hang (if we are near wall and press into it and our y velocity is exactly 0)
		- Wall climb (if we are near wall and press into it and our y velocity is < 0)
		- Ledge hang (if we are near ledge)
- Rope fall
	- Reset jump buffer for these cases
		- (rope fall -> idle -> jump)
		- (rope fall -> move -> jump)
		- (rope fall -> rope -> rope jump)
		- (rope fall -> ledge hang -> ledge climb)
	- States
		- Idle (if we hit ground and no movement input)
		- Move (If we hit ground and have movement input)
		- Rope (if we are near a rope and want to go up or down)
		- Rope jump (only if the coyote timer has time left, and we want to jump)
		- Wall slide (if we are near a wall, input into it)
		- Ledge hang (if we are near ledge)
- Wall slide
	- Reset jump buffer time for these cases
		- (wall slide -> idle -> jump)
		- (wall slide -> move -> jump)
		- (wall slide -> wall hang -> wall jump)
	- States
		- Idle (we hit ground and have no movement)
		- ~~Move (we hit ground and have movement)~~ Just let this be handled by Idle
		- Fall (we are no longer near a wall, because we fell off, ~~ or we want to drop by inputting 'down', or we try and change our direction)~~ Remove this as per below this entire list
		- Wall hang (our y velocity is 0)
- Wall hang
	- States
		- Fall (we want to drop by inputting 'down', or we try and change our direction)
		- Wall climb (we want to start climbing by inputting movement into the wall)
		- Wall jump (we want to jump, or if jump buffer still has time remaining)
- Wall climb
	- States
		- Fall (if we want to drop, or if we change direction)
		- Wall hang (if our y velocity is 0)
		- Wall jump (if we want to jump, or if jump buffer timer has time left)
		- Ledge grab (if we are near ledge)
- Wall jump
	- Misc
		- I would like to disable movement during the upwards part of this, actually! I will need to transition from the wall jump to a fall now
	- Reset jump buffer for these cases
		- (wall jump -> idle -> jump)
		- (wall jump -> move -> jump)
		- (wall jump -> rope -> rope jump)
		- (wall jump -> wall climb -> wall jump)
		- (wall jump -> wall hang -> wall jump)
		- (wall jump -> ledge hang -> ledge climb)
	- States
		- Idle (if a platform comes up to meet us, but no movement)
		- Move (if a platform comes up to meet us, and we have movement)
		- Fall (if y velocity > 0)
		- Rope (if we are near rope and want to go up or down)
		- Wall hang (if we are near wall and input into it and our y velocity is exactly 0)
		- Wall climb (if we are near wall and input into it and our y velocity is < 0)
		- Ledge hang (if we are near ledge)
- Ledge hang 
	- Misc
		- I think it is actually fine if we transition back to another ledge hang after either falling or 'ledge climbing' (which right now is just a jump), since in the future I will change it to an animation and there's kind of no reason to have either the `ledge_climb` or `ledge_fall` states
		- Basically delete the `ledge climb` and `ledge fall` states
	- States
		- Idle (if a platform comes up to us and we have no movement, check this by utilizing the FloorRayCast as well since touching wall would trigger `is_on_floor()` im pretty sure)
		- Move (same as above but if we have movement)
		- Fall (if we either want to drop by inputting 'down', or if we have movement that does not match our direction)
		- Ledge climb (if we jump or if jump buffer timer has time left)
- Ledge climb (current version)
	- Literally just switch this to 'jump' in the ledge hang export variables, and delete both the `ledge_climb` and `ledge_fall` scripts and states
- Ledge climb (future version)
	- Reset jump buffer for these cases
		- (ledge climb -> idle -> jump)
		- (ledge climb -> move -> jump)
		- (ledge climb -> rope -> rope jump)
	- States
		- Idle (if we finish animation and have no movement)
		- Move (if we finish animation and have movement)
		- Rope (if we finish animation, near rope, and try to go up or down it)

Other things to change:
- Jump -> Wall Climb : make this automatic
- Jump -> Wall hang : make this automatic
- Wall slide -> Fall : remove this
- Fall -> Wall hang : add a threshold so instead of entering wall slide, we can instead immediately enter wall hang
- Add coyote time to wall jumping, reset in wall hang and wall climb

Here are ~~all of the things~~ the things I remembered to include that were not part of the previous version of the states, before updating the states to match what I have written above!
- Coyote Time
	- Idle : reset in exit function, not enter function
	- Move : reset in exit function, not enter function
	- Rope : coyote time not reset
- Jump buffer
	- Jump : Not initiated in `process_physics()` when `get_jump()` is called
	- Fall : No longer uses the jump buffer to enter directly into a jump
	- Wall slide : Wasn't reset in `enter()` or initiated in `process_physics()`
	- Wall hang : unused to transition states
- State Transitions
	- Idle -> Jump : didn't check for jump buffer timer
	- Move -> Jump : didn't check for jump buffer timer
	- Jump -> Wall hang : transition nonexistent
	- Rope -> Rope fall : created state, inherits from 'fall'
	- Wall slide -> fall : no longer responds to user input
	- Wall hang -> wall jump : didn't check for jump buffer timer

Also, sadly we do still need to keep ledge climb and ledge fall as they are, at least unless there is a way for me to keep track of which states I have been in previously and exclude certain states from being transitioned to based on that... Which someone smarter than me has definitely figured out already.
- Maybe this is what a hierarchical state machine is for
- I am still going to clean up the duplicated code that I have so that transitioning to another state machine would be easier

Now that I have all of this implemented, what else do I want?
- If our velocity is under a certain threshold, stop when we hit an overhang of the wall while wall sliding as a saving grace
	- A really nice animation where our guy swings a little would be amazing
- If our velocity is under a certain threshold, enter a wall hang instead of wall slide when transitioning from falling
- There has to be a better way of maintaining these states than having these somewhat duplicated states that do slightly different things
- Make wall jumping feel better, because right now if you have the habit of holding a direction you just instantly fall right after jumping to another wall
	- Make player input the direction twice as a way to say 'hey are you sure bro?'
- I still want jump cutting and ledge magnetism
- Make the player enter a ledge hanging state if they press 'down' while standing / moving near a ledge
	- This is a FUCKING GREAT idea, would make the climbing feel very dynamic PLEASE DO THIS FUTURE ME
- Make walking down slopes not bouncy, look up how to do this because im sure it is a simple fix

# Upgrading our State machine

So we have a couple of problems so far. I feel like even though each state is unique, there is a LOT of duplicated calls to functions, and honestly writing out everything that I have up there is just way too much to keep track of. One thing that really bothers me right now is that we actually have to do this (wall hang -> wall fall -> rope jump) instead of (wall hang -> wall fall -> wall jump) because rope jump is just the exact same thing as wall jump, just with a reversed starting x velocity.

There's also this - I felt like I had a lot of situations where I would think about transitioning straight to a jump state from a state where it doesn't actually make sense to do so. Instead of doing something like (fall -> move -> jump), my first instinct was to instead do (fall -> jump) if the jump buffer was active. 

What if we took the same principle of delegating that responsibility of jumping to one of our ground states, but took it further? What if we had a structure like this that contains essentially everything we already have set up?

Player State Manager
- GroundStatesManager
	- Idle
	- Move
- AirStatesManager
	- Standard jump
	- Fall
	- Side jump
	- Reverse side jump
- WallStatesManager
	- Wall sliding
	- Wall climbing (includes wall hanging, since that doesn't need to really be a separate state until we get the overhang detection thing going)
- RopeStatesManager
	- Rope climbing
- LedgeStatesManager
	- Ledge hanging

Let's look at some situation that could happen.
1. We are currently in a wall climb, which is a state managed by our WallStatesManager
2. The PlayerStateManager contains the logic for detecting that we are near a ledge
3. During the physics process of the PlayerStateManager, we detect that we are near a ledge
4. The PlayerStateManager somehow tells the LedgeStateManager that we want to enter a LedgeState
5. We go to the LedgeStateManager
6. The LedgeStateManager examines our state, and finds that our jump buffer is not active
7. The LedgeStateManager decides that the state we should enter into is a Ledge hang

I don't know how to implement this yet, but I know that it would definitely cut down on repeated code if I got it working. Right now I have the check for if we want to enter a rope climb state in 7 different places, but this way it could just exist in our PlayerStateManager.

I spent the rest of my time today going over both of these videos, and honestly it was really hard and I will come back and rethink things tomorrow.
- [Code class - Build your own State Machines!](https://www.youtube.com/watch?v=-jkT4oFi1vk)
- [Code Class - Hierarchical State Machines](https://www.youtube.com/watch?v=Z0fmGAQSQG8&t=1565s)

Ok so here is how my current state machine works and how AdamCYounis' works
- Mine : Each frame, we call the physics_process function of an active state, and if that state decided that it needed to return a State which is different than itself, we change states and perform whichever logic is contained within it
	- All state logic and transitions to other states are handled within each State independently of each other, leading to lots of duplicated function calls and transitions
- AdamCYounis : Each frame, we call `Update()` (Unity's version of `physics_process()`) within our parent StateManager (PlayerManager, NPC) which will call `Do()` on our current State, and any substates down the hierarchy
	- We can communicate that a new state should be selected by a parent State or a StateManager with the `is_complete` variable
		- Communicating up the hierarchy
		- Example is setting `is_complete` to true if `state.time` > 1 in Collect, which then is seen by NPC state manager, which decides to set our new state to Patrol 
	- We can also forcibly `Set()` a child state within our State if certain conditions we decide are met
		- Deciding children states down the hierarchy
		- Example is setting our new state to Idle from within Collect, if we are in the Navigate state and are close enough to our target
	- Having both the option to `Set()` in our StateManager and our children States let's us centralize logic for switching into new states, and organize our States better

Here is the states organization from AdamCYounis
- NPC
	- Patrol State
		- Navigate State
		- Idle State
	- Collect State
		- Navigate
		- Idle

How would I organize my states with this approach?
- I should look through all of the states that I already have and put repeated logic inside the PlayerManager
- Since Adam thinks about the 'leaf' states as animations, maybe I should do that too

States diagram 
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

I am going to separate my pseudocode for each of the classes into their own md files since it is hard to keep track of everything when it is all together

Now that I have something working, I should try and figure out when we want to switch states. I currently have this structure:
- PlayerManager
	- Ground
		- Idle
		- Move
	- Air
		- Jump
		- Fall

PlayerManager
- Ground (if we are touching the ground)
	- Idle (if we have no input and our velocity is exactly 0)
	- Move (if we have input)
- Jump (if we pressed jump and our current state is Ground)
- Fall (if we are in the air and our y velocity is positive)
