extends State

# States we can transition to from this one
@export var fall_state: State
@export var idle_state: State
@export var move_state: State
@export var ledge_grab_state: State

@export var jump_force: float = 900.0

func enter() -> void:
	super()
	parent.velocity.y = -jump_force

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * max_speed
	parent.velocity.x = movement
	parent.velocity.y += gravity * delta
	if movement != 0:
		flip_animation_and_raycast(movement < 0)
	parent.move_and_slide()
	
	if parent.velocity.y > 0:
		return fall_state
	
	if parent.is_on_floor():
		if movement != 0:
			return move_state
		return idle_state
	
	if near_ledge():
		return ledge_grab_state
	
	return null
