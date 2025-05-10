extends State

@export var climbing_state: State
@export var dropping_state: State

func enter() -> void:
	super()
	parent.velocity.y = 0

func process_physics(delta: float) -> State:
	if get_jump():
		return climbing_state
	if get_movement_input() != 0:
		if get_movement_input() != get_direction():
			return dropping_state
	return null
	
