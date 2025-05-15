extends AirState

# States we can transition to from this one
@export var idle_state: State
@export var move_state: State
@export var jump_state: State
@export var rope_state: State
@export var ledge_hang_state: State
@export var wall_slide_state: State

func enter() -> void:
	super()
	parent.velocity.y = 0
	reset_jump_buffer_timer()

func process_physics(delta: float) -> State:
	if get_jump():
		jump_buffer_timer.start()
	
	# Keep outside of another if statement, or delta won't be called each frame
	if get_coyote_time(delta) && get_jump():
		return jump_state
	
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
	
	change_velocity_x(delta)
	parent.velocity.y = move_toward(parent.velocity.y, terminal_velocity, fast_gravity * delta)
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	# Make sure to check this before checking the wall!
	if near_ledge():
		snap_to_ledge()
		return ledge_hang_state
	
	if near_wall() && get_movement_input() != 0:
		return wall_slide_state
	
	if near_rope && (wants_up() or wants_drop()):
		return rope_state
	
	return null
