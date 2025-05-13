How should these work?

I know I need to use the signals so that we can detect when the player is able to grab onto the rope. I will create a custom state for traversing the rope, and that will be handled somewhere else.

I need to figure out what information I need the rope scene to provide in order to be useful.
- An x position, so that the player can match their x position to it while entering the rope state
	- This can be provided in the following ways (potentially)
		- The Area2D part of it, which is required to even put a sprite or collisionshape2d (the collisionshape2d is also required for sending a signal out)
		- The collisionshape2d part
		- I think anything that inherits a node2d actually has this property
- The signal for when our character's collisionshape2d enters it
	- If we are receiving this signal, it means that we can enter the rope state

That might actually be it? I think anything else can be handled inside of the state, such as when we are no longer touching the rope (like when we are too far under it and should enter falling state)

Here is a youtube video going over [how to use signals](https://www.youtube.com/watch?v=hWIiYhfP-PE)

Here is a youtube video about the [message bus pattern](https://www.youtube.com/watch?v=vbw1ncvSUYg), which I might need to connect these signals.
- A [link](https://www.gdquest.com/tutorial/godot/design-patterns/event-bus-singleton/) to the same concept

I feel like I'm just going to worry about figuring out how to get this signal thing to communicate with the player. I wonder if I can get the signal to give us our information as well?
