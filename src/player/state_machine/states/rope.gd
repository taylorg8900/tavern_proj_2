extends State

@export var idle_state: State
@export var move_state: State
@export var fall_state: State
@export var rope_jump_state: State

@export_range(0, 100, .5) var climb_speed : float = 50

func enter() -> void:
	super()
	parent.position.x = rope_pos
	parent.velocity.x = 0
	reset_coyote_time()

func process_physics(delta: float) -> State:
	
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
	
	if !near_rope: 
		return fall_state
	
	if get_jump():
		return rope_jump_state
	
	if wants_up():
		parent.velocity.y = move_toward(parent.velocity.y, -1 * climb_speed, delta * acceleration)
	elif wants_drop():
		parent.velocity.y = move_toward(parent.velocity.y, climb_speed, delta * acceleration)
	else:
		parent.velocity.y = move_toward(parent.velocity.y, 0, delta * deceleration)
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	return null
