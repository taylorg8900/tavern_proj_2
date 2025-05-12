extends State

@export var ledge_grab_state : State
@export var drop_state : State

@export_range(0, 100, .5) var climb_speed : float = 25

func enter() -> void:
	super()


func process_physics(delta: float) -> State:
	if near_ledge():
		snap_to_ledge()
		return ledge_grab_state
	
	if wants_drop():
		return drop_state
	
	if get_movement_input() != 0:
		if (get_movement_input() != get_direction()) or !near_wall():
			return drop_state
		parent.velocity.y = move_toward(parent.velocity.y, -1 * climb_speed, delta * acceleration)
	else:
		parent.velocity.y = move_toward(parent.velocity.y, 0, delta * deceleration)
	
	parent.move_and_slide()
	
	
	return null
