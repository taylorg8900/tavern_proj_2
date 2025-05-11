extends AirState

@export var idle_state: State
@export var move_state: State
@export var jump_state: State

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * max_speed
	parent.velocity.y += gravity * delta
	parent.velocity.x = movement
	if movement != 0:
		flip_animation_and_raycast(movement < 0)
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if movement != 0:
			return move_state
		if get_jump():
			return jump_state
		return idle_state
	
	return null
	
