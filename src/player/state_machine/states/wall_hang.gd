extends State

@export var climb_state: State
@export var drop_state: State

func enter() -> void:
	super()

func process_physics(delta: float) -> State:
	if get_movement_input() != 0:
		if get_movement_input() != get_direction():
			return drop_state
		return climb_state
	return null
