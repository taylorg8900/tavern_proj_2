extends AirState

# States we can transition to from this one
@export var idle_state: State
@export var move_state: State
@export var fall_state: State
@export var rope_state: State
@export var wall_hang_state: State
@export var wall_climb_state: State
@export var ledge_hang_state: State

@onready var jump_velocity : float = (-2.0 * jump_height) / jump_time_to_peak

var switch_to_fast_gravity : bool = false

func enter() -> void:
	super()
	parent.velocity.y = jump_velocity
	switch_to_fast_gravity = false
	reset_jump_buffer_timer()

func process_physics(delta: float) -> State:
	change_velocity_x(delta)
	
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
	
	if get_jump():
		jump_buffer_timer.start()
	
	if !Input.is_action_pressed("jump"):
		switch_to_fast_gravity = true
	
	if switch_to_fast_gravity:
		parent.velocity.y += fast_gravity * delta
	else:
		parent.velocity.y += jump_gravity * delta
	
	if parent.velocity.y > 0:
		return fall_state
	
	# Keep before `parent.is_on_floor()` check
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	if near_wall():
		if parent.velocity.y == 0:
			return wall_hang_state
		return wall_climb_state
	
	if near_ledge():
		snap_to_ledge()
		return ledge_hang_state
	
	if near_rope && (wants_drop() or wants_up()):
		return rope_state
	
	return null
