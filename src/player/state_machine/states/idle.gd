extends State

# States we can transition to from this one
@export var move_state: State
@export var jump_state: State
@export var fall_state: State
@export var rope_state: State

func enter() -> void:
	super()
	parent.velocity.x = 0
	reset_coyote_time()

func process_physics(delta: float) -> State:
	
	if get_movement_input() != 0.0:
		return move_state
	
	if parent.is_on_floor():
		if get_jump() or get_jump_buffer_timer():
			return jump_state
	else:
		return fall_state
	
	if near_rope && wants_up():
		return rope_state
	
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	return null
