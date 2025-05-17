What would my 'core' class look like?
```
class_name StateManagerCore

default Godot nodes present in every player / npc / enemy, see if we can export these?
	- CollisionObject2d or PhysicsBody2d, the thing that CharacterBody2d inherits from that is generic
	- AnimatedSprite2d
	- CollisionShape2d
	- Label (for now)

instantiate a StateMachine object named state_machine here so that states can manage their own children states

function SetUpStates() to instantiate the core in every child of a StateManager that is also a State
	- probably use get_children
```
