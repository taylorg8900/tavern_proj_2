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
- Yes, you can do that
- I have an autoloaded script named Signals, and this is how I connected to it with the x position: `Signals.rope_entered.emit(get_parent().position.x)`
- In Signals, here is the signal itself: `signal rope_entered(x_pos: int)`
- And here is wherever we want to access the information: `Signals.rope_entered.connect(FUNCTION_NAME)`

I need some way of knowing if we are near the rope, just like if we are near a ledge. So far I have a signal that just prints out to the screen that we walked past it, but we have no way of checking each frame if we are still in front of it.

```
func near rope
	return (if signal is being emitted this frame)
```

I need some way of the signal either being emitted each frame while we are near it, or to keep track of if we have entered and haven't left yet. I'm not that smart but it feels wrong for the signal to be emitted each frame, when where it comes from only triggers once when something interesting happens. I think I need some variable to keep track of it inside of the State class instead.
- I decided to keep track with a bool, and another variable to keep track of the position as well

Right now, the rope will send a signal anytime a Node2D enters, but this is a problem because in the future it will detect anything at all. I want to only update these values if the player specifically triggered the signal. How do I do this?
- I asked chatGPT and it has a few options for me
	- Add the player to a 'group', which is in the Node tab next to the Inspector. Check the group each time we emit the signal in the rope script.
		- This isn't wrong, but I don't want to necessarily couple them together like that
	- Since my Player is a custom Class, I could include this line inside of the rope script: `if body is Player:`
		- This is the same as above, but I feel like maybe it is worse because now it is even more coupled
	- Set the collision layer to only respond to the same one that the player is on
		- This is super tedious and I'm just not going to do it
- My idea is what if we also emitted the type of Node2D that entered, along with the x position? And then in the player stuff we can check for that.
