extends State

@export var fall_state: State
@export var climb_state: State
@export var wall_jump_state: State

func enter() -> void:
	super()
	reset_coyote_time()


func process_physics(delta: float) -> State:
	if wants_drop():
		return fall_state
	if get_jump() or get_jump_buffer_timer():
		return wall_jump_state
	if get_movement_input() != 0:
		if get_movement_input() != get_direction():
			return fall_state
		return climb_state
	return null
