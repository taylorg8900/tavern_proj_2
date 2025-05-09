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
	- We need a value to add to the x velocity each call by multiplying it with delta
	- We need to define a maximum x velocity value
