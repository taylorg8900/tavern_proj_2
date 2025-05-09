extends State

# States we can transition to from this one
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State
@export var sprint_state: State

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * move_speed
	parent.velocity.y += gravity * delta
	parent.velocity.x = movement
	parent.move_and_slide()
	
	if movement == 0:
		return idle_state
	else:
		if get_sprint():
			return sprint_state
	
	# Put this after the idle_state check so the player model doesn't flip back on accident
	animations.flip_h = movement < 0
	
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	if !parent.is_on_floor():
		return fall_state
	return null
