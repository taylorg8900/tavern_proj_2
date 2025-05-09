class_name State
extends Node

@export var animation_name: String
@export var move_speed: float = 100
@export var label_text: String

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var parent: CharacterBody2D
var animations: AnimatedSprite2D
var label: Label

func enter() -> void:
	animations.play(animation_name)
	label.text = label_text

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func process_frame(delta: float) -> State:
	return null

func get_movement_input() -> float:
	return Input.get_axis('move_left', 'move_right')


# Return a boolean indicating if the character wants to jump
func get_jump() -> bool:
	return Input.is_action_just_pressed('jump')
