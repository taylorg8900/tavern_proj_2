extends State

@export var idle_state: State
@export var move_state: State
@export var fall_state: State
@export var wall_jump_state: State

@export_range(0, 100, .5) var climb_speed : float = 50

func enter() -> void:
	super()
	parent.position.y -= 1
	parent.position.x = rope_pos
	parent.velocity.x = 0
	has_jumped = false


func process_physics(delta: float) -> State:
	
	#if get_jump():
		#return wall_jump_state
	
	if get_movement_input() != 0:
		flip_animation_and_raycast(get_movement_input() < 0)
	if get_jump():
		flip_animation_and_raycast(get_direction() > 0)
		return wall_jump_state
	elif Input.is_action_pressed('up'):
		parent.velocity.y = move_toward(parent.velocity.y, -1 * climb_speed, delta * acceleration)
	elif Input.is_action_pressed('down'):
		parent.velocity.y = move_toward(parent.velocity.y, climb_speed, delta * acceleration)
	else:
		parent.velocity.y = move_toward(parent.velocity.y, 0, delta * deceleration)
	
	parent.move_and_slide()
	
	if !near_rope: 
		return fall_state
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	return null
