extends AirState

@export var idle_state: State
@export var move_state: State
@export var jump_state: State

func process_physics(delta: float) -> State:
	parent.velocity.y = move_toward(parent.velocity.y, terminal_velocity, fast_gravity * delta)
	change_velocity_x(delta)
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		if get_jump():
			return jump_state
		return idle_state
	
	return null
	
