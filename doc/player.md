# Player movement

The first thing I need to check out is something called a state machine. I'm not sure how this works yet, but I want some behaviors that can be inherited by enemies later, and figuring out how to implement a state machine for the player seems like a good start.

Here is a seemingly good video on [state machines](https://www.youtube.com/watch?v=-ZP2Xm-mY4E)

After taking notes on state machines, I need to figure out what some of the movement I want can be specifically for the player.

Potential states
	- Movement
		- Walking
		- Running
		- Jumping
		- Climbing
		- Big climbing (using the axe to go higher)
		- Slowing fall (falling but using the axe to slow, like grabbing the wall and going slower)
		- Hanging, coming to a deadstop
		- Descending down ropes 
		- Swinging from the grapples that are shot out by crossbow
	- Combat
		- Shielding
		- Shield bash
		- Attacking
		- Throwing runestones
		- Hiding (from enemies)
		- Using crossbow
	- Runestone states
		- Teleporting
		- Travelling through the walls like an alter Q
		- Feather falling
		- Time rune
	- Misc
		- Healing
		- Lighting fires manually
		- Mining (gems / ores)

What are some common player movement things that I should include to make moving around feel more fluid?
	- Coyote time
	- Jump buffering (when you hit the jump button before you actually hit the ground)
	- Variable jump height
	- Jump cutting (when you release button early, stop moving upwards)
	- Hang time at the top of a jump
	- Acceleration and deceleration
	- Having air control not be the exact same as when you are on the ground, less responsive
	- Corner correction (moves the player a little horizontally, avoids pixel perfect collisions which are annoying)
	- Ledge magnetism (moves the player over a few pixels if they just barely would have missed otherwise)

This [video](https://www.youtube.com/watch?v=hG9SzQxaCm8) is apparently really good for making a custom jump function

# Player upgrades

Health
	- Beard
		- Upgrade by buying things like beard oil, hair care products etc
		- Restore health with washing beard, getting trims done, etc


# Player Actions

I need to first identify which items the player can interact with. This is on the level of which tools they use, what weapons are available to them, that sort of thing.
- Pickaxe / Axe tool
- Lantern
- Ale
- Shield
- Minecarts
- Runestones
- Rucksack
- Crossbow

Now, I will brainstorm potential uses for each item.
- Pickaxe / Axe tool
	- Common uses
		- Mining ores, gems, and decayed structures
		- Hitting enemies
		- Throwing at enemies
		- Slowing descents down walls, and coming to a stop
	- Less common uses
		- Starting rockslides by hitting sections of the cave which are unstable, to cut off enemies
		- Cutting ropes if enemies are climbing them
		- Climbing up ledges which are just out of reach, like ice climbing picks
		- Hanging onto walls
	- Upgrades
		- Sharpened (more damage to enemies)
		- Increase amount of ores / gems obtained, like fortune enchantment in minecraft
		- Upgrade by actually enchanting it with the help of the wizard you buy runestones from
- Lantern
	- Upgrades
		- Make the flame last longer, giving the player more time they can spend inside missions (like oxygen tank from dave the diver)
	- Common uses
		- Lighting up environment
- Ale
	- Upgrades
		- Increase potency of healing / stamina / buff ales
		- Do this by 'spiking' drinks with minerals found in the caves / mines
	- Common uses
		- Healing
		- Refill stamina
		- Buffs applied before mission
			- The player can brew custom beers and get some bonuses before the level starts. I think this could be a good way to reduce inventory clutter or giving the player too many hotkeys or keybinds to worry about, since we already use ale for healing and stamina anyway.
			- Damage boost
			- Speed boost
			- Increase carry capacity
			- Drunkenness (increase effect of healing and stamina further, because more drunk = more dwarven)
			- Night vision (increases how far the lantern's light goes for player)
			- Cozy (increases health regen speed - "This ale reminds me of my childhood!")
			- Chilled (reduces damage from fire, lava, etc)
			- Spicy (reduces damage from ice or something idk)
- Shield
	- Upgrades
		- Reduce damage taken from enemies
		- Increase movement speed while blocking
	- Common uses
		- Blocking enemies duh
		- Ramming into enemies to create space at the cost of some health
		- Movement
			- Sliding around, sledding down slopes
- Runestones
	- Upgrades
		- Just increase potency of whichever runestone, not rocket science
		- Increase distance you can throw them, speed you can throw them, etc
		- Increase amount in the 'goodie bags' by spending gold, permanent upgrade
		- Increase 'luck' (amount of loot in the key and lock style generation) by "Giving the mines back some of it's fortune" or something like that
	- Creation / Purchasing
		- Use gems specifically for this? Like crafting them before missions
			- Buy from a wizard with both gems and gold, so you need specific items to get specific runestones
		- Find naturally in environment analagous to keys and locked chests
		- Can buy 'goodie bags' full of a random assortment of them with just gold 
			- Display some kind of tooltip that shows the player potentially what they could get out of it before buying, like some bags are more focused on sight, some are more focused on explosions etc
	- Common uses
		- Enemy effects
			- Slow down enemy
			- Make enemy do less damage
			- Make enemy have less health
			- Freeze enemy
		- Damage
			- Fireball
			- Mine type explosions
			- Grenade type explosions
			- Soft launch style explosion
			- Light (stuns, I imagine enemies in caves are sensitive to light)
			- Lava
				- Similar to spikes (see below)
			- Spikes
				- Ice spikes and rock spikes
				- Like an airburst shell that shoots shrapnel out when it is going to hit an enemy
			- Midas
				- Turns an enemy completely into gold, very valuable and rare, cannot be crafted
		- Sight
			- Throwing into rooms to detect if there enemies
			- Keeping a glimmering light which can be seen through walls, fancy blueish orb that floats there
			- Showing fastest way back to the start of the level
			- Showing where gems or loot is
			- Firespark
				- Will light up any torches, fireplaces, campfires, whatever that have line of sight to where the runestone hits to provide static light to player
		- Barricades
			- Firewall (blocks an area, like a call of duty zombie trap)
			- Moss 
				- On top of looking nice, this can slow down enemies that walk into it
		- Puzzles
			- Getting rid of water / lava / things in the way, like finding keys that go to locked doors or chests
		- Player Effects
			- Make player faster for a period of time
			- Time rune
				- Makes player faster, makes everything else slower
			- Providing 'feather falling' when falling from large heights
			- Travelling through a wall or floor like an alter Q from Apex Legends
			- Teleporting to a set location (common trope in all sorts of games)
			- Remotely retrieving an object, by making the object behave like thor's hammer or something when it hits it
				- Could control the path the stone travels by similar to boomerang mechanic from the DS zelda games where you draw a line first for it to follow
			- Cloaking the player
			- 'Melting' ores the player has found, to make them smaller and easier to carry (Take up less space in inventory?)
- Minecarts
	- Common uses
		- Carrying ores for the player
			- If I had it set up like multiple checkpoints such as REPO, this could be a good tile design where the player can dump things into it and send it off
		- Very fast travel speed, like terraria minecarts
		- Special mission types where the player has to escort it for big profit, defend objective kind of thing
- Rucksack
	- Upgrades
		- Increase grid size of bag, to hold more items
		- Increase amount of runestones it can hold
		- Increase amount of Ale flasks it can hold
	- Common uses
		- Used to store ores, gems the player finds. Uses an inventory system like in Delta Force where different items have a different size they take up. The rucksack can be upgraded to hold more items by increasing the grid size inside, and runestones can decrease the size of ores / gems found within missions to make it so you can carry even more.
- Crossbow
	- Common uses
		- Shooting enemies duh
		- Grappling and swinging around the environment on certain structures, like Legend of Zelda Wind Waker grappling hook
