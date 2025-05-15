# Copy of fall state, but we can't enter another ledge hang
# Change this in the future since copy pasting makes me cringe
extends AirState

@export var idle_state: State
@export var move_state: State
@export var jump_state: State
@export var rope_climb_state: State
@export var wall_slide_state: State

func enter() -> void:
	super()
	parent.velocity.y = 0
	reset_jump_buffer_timer()

func process_physics(delta: float) -> State:
	parent.velocity.y = move_toward(parent.velocity.y, terminal_velocity, fast_gravity * delta)
	change_velocity_x(delta)
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
		
	parent.move_and_slide()
	
	if get_jump():
		jump_buffer_timer.start()
	
	if parent.is_on_floor():
		if get_jump_buffer_timer():
			return jump_state
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	if near_wall() && get_movement_input() != 0:
		return wall_slide_state
	
	if near_rope and (wants_up() or wants_drop()):
		return rope_climb_state
	
	return null
