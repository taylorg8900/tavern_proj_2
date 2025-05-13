extends State

@export var idle_state: State
@export var move_state: State
@export var fall_state: State
@export var wall_jump_state: State

@export_range(0, 100, .5) var climb_speed : float = 50

func process_physics(delta: float) -> State:
	
	if get_jump() or wants_up():
		parent.velocity.y = move_toward(parent.velocity.y, -1 * climb_speed, delta * acceleration)
	
	if wants_drop():
		parent.velocity.y = move_toward(parent.velocity.y, climb_speed, delta * acceleration)
	
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
		parent.velocity.y = move_toward(parent.velocity.y, -1 * climb_speed, delta * acceleration)
		if get_jump():
			return wall_jump_state
	else:
		parent.velocity.y = move_toward(parent.velocity.y, 0, delta * deceleration)
	
	if !near_rope: 
		return fall_state
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	return null
