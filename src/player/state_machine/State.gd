class_name State
extends Node

@export var animation_name: String
@export var max_speed: float = 95
@export var label_text: String
@export_range(0, 1, 0.01) var coyote_time: float = .1
@export_range(0, 1, 0.01) var jump_buffer: float = .1

@export_range(0, 1, 0.01) var seconds_to_reach_max_speed: float = .1
@export_range(0, 1, 0.01) var seconds_to_reach_zero_speed: float = .1

@onready var acceleration = max_speed / seconds_to_reach_max_speed
@onready var deceleration = max_speed / seconds_to_reach_zero_speed

# variables that get set by our State Manager
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var parent: CharacterBody2D
var animations: AnimatedSprite2D
var label: Label
var top_raycast: RayCast2D
var wall_raycast: RayCast2D
var floor_raycast: RayCast2D
var air_raycast: RayCast2D
var hand_position: Marker2D

# Everything else
static var has_jumped = false # keeps track of coyote time
static var will_jump = false # keeps track of jump buffer

static var ropes : Array
static var near_rope = false
static var rope_pos = null

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

func wants_up() -> bool:
	return Input.is_action_just_pressed('up')

func get_coyote_time() -> void:
	pass

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

func get_ledge_offset() -> Vector2:
	var intersection = Vector2(wall_raycast.get_collision_point().x, air_raycast.get_collision_point().y)
	var target_pos = hand_position.global_position
	return intersection - hand_position.global_position

func snap_to_ledge() -> void:
	parent.position += get_ledge_offset()

func entered_rope(node_entered: Node2D, rope: Node2D, x_pos: int) -> void:
	if node_entered is Player:
		near_rope = true
		ropes.append(rope.get_instance_id())
		rope_pos = x_pos

func exited_rope(node_entered: Node2D, rope: Node2D) -> void:
	if node_entered is Player:
		ropes.erase(rope.get_instance_id())
		if ropes.is_empty():
			near_rope = false
			rope_pos = null
	
