extends AirState

# States we can transition to from this one
@export var idle_state: State
@export var move_state: State
@export var ledge_grab_state: State
@export var wall_slide_state: State


func enter() -> void:
	super()
	parent.velocity.y = 0

func process_physics(delta: float) -> State:

	#parent.velocity.y += fast_gravity * delta
	parent.velocity.y = move_toward(parent.velocity.y, terminal_velocity, fast_gravity * delta)
	change_velocity_x(delta)
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	if near_ledge():
		return ledge_grab_state
	
	if near_wall():
		return wall_slide_state
	
	return null
