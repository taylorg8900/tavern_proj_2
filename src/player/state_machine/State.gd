class_name State
extends Node

@export var animation_name: String
@export var move_speed: float = 400

var parent: CharacterBody2D
var animations: AnimatedSprite2D
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_component

func enter() -> void:
	animations.play(animation_name)

func exit() -> void:
	pass

func process_input(event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	return null

func get_movement_input() -> float:
	return move_component.get_movement_direction()

func get_jump() -> bool:
	return move_component.wants_jump()
