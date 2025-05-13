class_name State
extends Node

@export var animation_name: String
@export var max_speed: float = 95
@export var label_text: String

@export_range(0, 1, 0.01) var seconds_to_reach_max_speed: float = .1
@export_range(0, 1, 0.01) var seconds_to_reach_zero_speed: float = .1

@onready var acceleration = max_speed / seconds_to_reach_max_speed
@onready var deceleration = max_speed / seconds_to_reach_zero_speed

@onready var near_rope = false
@onready var rope_pos = null

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var parent: CharacterBody2D
var animations: AnimatedSprite2D
var label: Label
var top_raycast: RayCast2D
var wall_raycast: RayCast2D
var floor_raycast: RayCast2D
var air_raycast: RayCast2D
var hand_position: Marker2D

func _ready() -> void:
	Signals.rope_entered.connect(entered_rope)
	Signals.rope_exited.connect(exited_rope)

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

func get_jump() -> bool:
	return Input.is_action_just_pressed('jump')

func wants_drop() -> bool:
	return Input.is_action_just_pressed('down')

func flip_animation_and_raycast(flip: bool) -> void:
	animations.flip_h = flip
	if flip:
		top_raycast.rotation_degrees = 180
		wall_raycast.rotation_degrees = 180
		air_raycast.position.x = -1 * abs(air_raycast.position.x)
		hand_position.position.x = -1 * abs(hand_position.position.x)
	else:
		top_raycast.rotation_degrees = 0
		wall_raycast.rotation_degrees = 0
		air_raycast.position.x = abs(air_raycast.position.x)
		hand_position.position.x = abs(hand_position.position.x)

func get_direction() -> float:
	if animations.flip_h:
		return -1
	return 1

func near_ledge() -> bool:
	return (!top_raycast.is_colliding() && wall_raycast.is_colliding())

func near_wall() -> bool:
	return wall_raycast.is_colliding() 

func change_velocity_x(delta: float) -> void:
	if get_movement_input() != 0:
		parent.velocity.x = move_toward(parent.velocity.x, get_movement_input() * max_speed, acceleration * delta)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, deceleration * delta)

func get_offset() -> Vector2:
	var intersection = Vector2(wall_raycast.get_collision_point().x, air_raycast.get_collision_point().y)
	var target_pos = hand_position.global_position
	return intersection - hand_position.global_position

func snap_to_ledge() -> void:
	parent.position += get_offset()

func entered_rope(x_pos: int, node_type: Node2D) -> void:
	if node_type is Player:
		near_rope = true
		rope_pos = x_pos

func exited_rope(node_type: Node2D) -> void:
	if node_type is Player:
		near_rope = false
		rope_pos = null
	
