extends AirState

# States we can transition to from this one
@export var idle_state: State
@export var move_state: State
@export var jump_state: State
@export var rope_state: State
@export var ledge_hang_state: State
@export var wall_slide_state: State

func enter() -> void:
	super()
	parent.velocity.y = 0
	reset_jump_buffer_timer()


func process_physics(delta: float) -> State:
	if near_ledge():
		snap_to_ledge()
		return ledge_hang_state
	
	if get_coyote_time(delta) && get_jump():
		return jump_state
	
	parent.velocity.y = move_toward(parent.velocity.y, terminal_velocity, fast_gravity * delta)
	
	
	if get_movement_input() != 0:
		change_velocity_x(delta)
		flip_animation_and_raycast(get_movement_input() < 0)
	
	if near_wall() && get_movement_input() != 0:
		return wall_slide_state
	parent.move_and_slide()
	
	if get_jump():
		jump_buffer_timer.start()
	print(jump_buffer_timer.time_left)
	
	if parent.is_on_floor():
		if get_jump_buffer_timer():
			return jump_state
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	
	if (near_rope && Input.is_action_pressed('up')) or (near_rope && Input.is_action_pressed("down")):
		return rope_state
	
	return null
