extends AirState

# States we can transition to from this one
@export var fall_state: State
@export var idle_state: State
@export var move_state: State
@export var wall_climb_state: State
@export var ledge_grab_state: State

@onready var jump_velocity : float = (-2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)



var switch_to_fast_gravity : bool = false

func enter() -> void:
	super()
	parent.velocity.y = jump_velocity
	switch_to_fast_gravity = false


func process_physics(delta: float) -> State:
	change_velocity_x(delta)
	
	if switch_to_fast_gravity:
		parent.velocity.y += fast_gravity * delta
	else:
		parent.velocity.y += jump_gravity * delta
	
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
	
	parent.move_and_slide()
	
	if parent.velocity.y > 0:
		return fall_state
	
	if near_wall() && get_movement_input() != 0:
		return wall_climb_state
			
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	if near_ledge():
		return ledge_grab_state
	
	if !Input.is_action_pressed("jump"):
		switch_to_fast_gravity = true
	
	return null
