class_name State
extends Node

@export var animation_name: String
@export var max_speed: float = 100
@export var label_text: String

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var parent: CharacterBody2D
var animations: AnimatedSprite2D
var label: Label
var top_raycast: RayCast2D
var bottom_raycast: RayCast2D

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

func flip_animation_and_raycast(flip: bool) -> void:
	animations.flip_h = flip
	if flip:
		top_raycast.rotation_degrees = 180
		bottom_raycast.rotation_degrees = 180
	else:
		top_raycast.rotation_degrees = 0
		bottom_raycast.rotation_degrees = 0

func get_direction() -> float:
	if animations.flip_h:
		return -1
	return 1

func near_ledge() -> bool:
	return !top_raycast.is_colliding && bottom_raycast.is_colliding
