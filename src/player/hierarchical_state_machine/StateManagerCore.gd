extends Node

class_name StateManagerCore

@export var body : CharacterBody2D
@export var animation : AnimatedSprite2D
@export var collision_shape : CollisionShape2D
@export var label : Label

var state_machine = StateMachine.new()

func SetUpStates(node : Node) -> void:
	var children = node.find_children("", "State")
	for child in children:
		child.SetCore(self)
