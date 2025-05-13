extends AirState

# States we can transition to from this one
@export var idle_state: State
@export var move_state: State
@export var ledge_hang_state: State
@export var wall_slide_state: State

func enter() -> void:
	super()
	parent.velocity.y = 0

func process_physics(delta: float) -> State:
	if near_ledge():
		snap_to_ledge()
		return ledge_hang_state

	parent.velocity.y = move_toward(parent.velocity.y, terminal_velocity, fast_gravity * delta)
	change_velocity_x(delta)
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
		
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	if near_wall() && get_movement_input() != 0:
		return wall_slide_state
	
	return null
