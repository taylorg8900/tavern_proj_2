extends State

# States we can transition to from this one
@export var fall_state: State
@export var idle_state: State
@export var move_state: State
@export var ledge_grab_state: State

@export var jump_height : float
@export_range(0, 1, .01) var jump_time_to_peak : float
@export_range(1, 4, .1) var variable_jump_gravity_mult : float

@onready var jump_velocity : float = (-2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var variable_gravity : float = jump_gravity * variable_jump_gravity_mult

var switch_to_variable_gravity : bool = false

func enter() -> void:
	super()
	parent.velocity.y = jump_velocity
	switch_to_variable_gravity = false

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * max_speed
	parent.velocity.x = movement
	if switch_to_variable_gravity:
		parent.velocity.y += variable_gravity * delta
	else:
		parent.velocity.y += jump_gravity * delta
	if movement != 0:
		flip_animation_and_raycast(movement < 0)
	parent.move_and_slide()
	
	if parent.velocity.y > 0:
		return fall_state
	
	if parent.is_on_floor():
		if movement != 0:
			return move_state
		return idle_state
	
	if near_ledge():
		return ledge_grab_state
	
	if !Input.is_action_pressed("jump"):
		switch_to_variable_gravity = true
	
	return null
