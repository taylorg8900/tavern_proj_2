class_name State
extends Node

@export var animation_name: String
@export var max_speed: float = 95
@export var label_text: String

@export_range(0, 1, 0.01) var seconds_to_reach_max_speed: float = .1
@export_range(0, 1, 0.01) var seconds_to_reach_zero_speed: float = .1

@onready var acceleration = max_speed / seconds_to_reach_max_speed
@onready var deceleration = max_speed / seconds_to_reach_zero_speed

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var parent: CharacterBody2D
var animations: AnimatedSprite2D
var label: Label
var top_raycast: RayCast2D
var bottom_raycast: RayCast2D
var floor_raycast: RayCast2D

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
	# near ledge if only bottom_raycast is colliding
	#print("Top:", top_raycast.is_colliding(), " Bottom:", bottom_raycast.is_colliding(), " Floor:", floor_raycast.is_colliding())
	return (!top_raycast.is_colliding() && bottom_raycast.is_colliding()) && !floor_raycast.is_colliding()

func near_wall() -> bool:
	return top_raycast.is_colliding() 

func change_velocity_x(delta: float) -> void:
	if get_movement_input() != 0:
		parent.velocity.x = move_toward(parent.velocity.x, get_movement_input() * max_speed, acceleration * delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, deceleration * delta)

func get_diagonal_input() -> float:
	if Input.is_action_pressed("move_left") && Input.is_action_pressed("up"):
		return -1
	elif Input.is_action_pressed("move_right") && Input.is_action_pressed("up"):
		return 1
	return 0
