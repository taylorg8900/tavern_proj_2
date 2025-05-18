extends Node

class_name StateManagerCore

@export var body : CharacterBody2D
@export var animation : AnimatedSprite2D
@export var collision_shape : CollisionShape2D
@export var label : Label

var state_machine = StateMachine.new()

func SetUpStates() -> void:
	var children = get_children()
	for item in children:
		if item is State:
			item.SetCore(self)
		# Recursive call so we can search through the entire scene's tree
		item.SetUpStates()
