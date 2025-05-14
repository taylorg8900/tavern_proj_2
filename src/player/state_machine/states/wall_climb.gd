extends State

@export var fall_state : State
@export var wall_jump_state: State
@export var ledge_hang_state : State


@export_range(0, 100, .5) var climb_speed : float = 25

func enter() -> void:
	super()


func process_physics(delta: float) -> State:
	if near_ledge():
		snap_to_ledge()
		return ledge_hang_state
	
	if wants_drop():
		return fall_state
	
	if get_jump() or get_jump_buffer_timer():
		return wall_jump_state
	
	if get_movement_input() != 0:
		if (get_movement_input() != get_direction()) or !near_wall():
			return fall_state
		parent.velocity.y = move_toward(parent.velocity.y, -1 * climb_speed, delta * acceleration)
	else:
		parent.velocity.y = move_toward(parent.velocity.y, 0, delta * deceleration)
	
	parent.move_and_slide()
	
	return null
