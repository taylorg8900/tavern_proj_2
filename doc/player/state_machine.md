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
