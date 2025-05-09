# Movement state machine - basic

Here are all of the (current) states that the player can be in, for moving. I will definitely need to have multiple state machines later to handle things like combat, healing, etc at the same time. But since I haven't ever done anything with state machines, I want to just implement a basic one to take care of moving around before getting into everything else.
	- Idle
	- Walking
	- Sprinting
	- Jumping
	- Falling
	- Climbing by grabbing the edge of ledge
	- Big climbing (using the axe to go higher than normal climbing)
	- Slowing fall (falling but using the axe to slow, like grabbing the wall and slowing down)
	- Hanging, coming to a deadstop
	- Descending down ropes
	- Swinging from the grapples that are shot out by crossbow

For now, I am only going to worry about these ones
	- Idle
	- Walking
	- Sprinting
	- Jumping
	- Falling
	- Climbing by grabbing the edge of ledge

Here are the states that can be transitioned to from each current state
	- Idle
		- Walking (player inputs movement)
		- Sprinting (player starts moving, but is already holding sprint key)
		- Jumping (player inputs jump)
		- Falling (if the player's y velocity > 0, like if something breaks under them)
	- Walking
		- Idle (player hits a wall or is no longer providing movement input)
		- Sprinting ()
		- Jumping
		- Falling
	- Sprinting
		- Idle (player hits a wall, or stops moving)
		- Walking (player runs out of stamina, stops sprinting)
		- Jumping
		- Falling
	- Jumping
		- Idle (don't expect this to ever happen, but if something catches up to the player and now they are standing on top of it)
		- Falling
		- Climbing
	- Falling
		- Idle
		- Walking
		- Sprinting
		- Jumping (jump buffering goes here)
		- Climbing
	- Climbing by grabbing the edge of ledge
		- Idle
		- Walking
		- Sprinting
		- Jumping

I am going to be using the implementation that The Shaggy Dev uses in his [youtube video](https://www.youtube.com/watch?v=bNdFXooM1MQ&list=PLaiU9HSaKMWtmAIR345HGIz_ijQiyr3kH&index=7), and when I am comfortable with how it works I will start doing my own thing.

How does it work?
	- Each state inherits a class named `State` that has methods which can return other states, but by default will return `null`.
	- The state machine will only switch into another state and call it's `enter` function when it receives a return value that is *not* `null`.
	- In this way, we will stay inside of a state every frame until it is decided that it should switch into something else in either the `process_input` or `process_physics` function.
	- We can have special behavior inside of the `enter` function like setting a velocity to a certain value, and state specific values (which are exported to the Inspector for easy modification)
