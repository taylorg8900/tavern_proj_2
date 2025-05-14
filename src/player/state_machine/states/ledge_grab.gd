extends State

@export var jump_state: State
@export var drop_state: State

func enter() -> void:
	super()
	parent.velocity.y = 0

func exit() -> void:
	reset_coyote_time()

func process_physics(delta: float) -> State:
	if wants_drop():
		return drop_state
	if get_jump():
		return jump_state
	if get_movement_input() != 0:
		if get_movement_input() != get_direction():
			#flip_animation_and_raycast(get_movement_input() < 0)
			return drop_state
	return null
	
