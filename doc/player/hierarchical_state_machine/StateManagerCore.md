What would my 'core' class look like?
```
class_name StateManagerCore

default Godot nodes present in every player / npc / enemy, see if we can export these?
	- body : CollisionObject2d or PhysicsBody2d, the thing that CharacterBody2d inherits from that is generic
	- animations : AnimatedSprite2d
	- Label (for now)

var state_machine : StateMachine (so our Manager can use it)

function SetUpStates() to instantiate the core in every child of a StateManager that is also a State
	- probably use get_children
	- call SetUpCore(this) on each state it finds
		- because we will use this in classes that inherit, it will give our variables and functions to them too
```
