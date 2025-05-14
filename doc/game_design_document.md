# Progression

Here I will note down which things I worked on, in order. This is for me to look back on in the future. If I make a devlog or something it would be really handy.
- player.md, trying to figure out all of the things I would like the player to do and use
- state_machine.md, learning how to implement a state machine and creating my own states
- rope.md, and the rope state, learned how signals work and how to attach them to a global autoload script to be accessed anywhere
- state_machine.md, implementing things like coyote time and jump buffering, learned you can use static typing in Godot


# Story

Version 1
	- The player inherits a tavern where the minerals underneath it are used to manufacture drugs. The player sells these minerals to an organization that sells drugs, and they extort the player to go down and get more and more out of the mines as time goes on. 
	
Version 2
	- The player is a sort of mercenary dwarf, who lingers around taverns and finds local jobs available which are posted on message boards inside the taverns or by talking to patrons. You order ale before each mission, buy runestones from wizards, upgrade gear by buying from wandering merchants, etc. You are just a dwarf travelling around hoping to hit it big someday by taking these odd jobs.
	- Like soda dungeon I guess
	
# Artstyle

I was messing around with the pickaxe axe tool, and while trying to rotate it I realized that it gets abstracted way too much to even be cohesive. There was a [youtube video](https://www.youtube.com/shorts/FCJWPYqV0TI) that I found that solves the issue by just not dealing with creating a new sprite for each rotation, and I really like this solution. I especially like it because having subpixel movement would make the game look smoother anyway, so I should embrace it and save lots of effort on animating.

For the running animation, my old one where the character bounces up and down I don't really like too much. I don't want to have to deal with rotating the pickaxe, or having the hands move around a ton. I really like [this reddit post](https://www.reddit.com/r/PixelArt/comments/1gfwnd1/running_animation_tutorial_hopefully_this_will/), because the movement isn't erratic and is easy on the eyes.
