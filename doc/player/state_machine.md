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