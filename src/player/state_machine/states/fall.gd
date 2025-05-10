extends State

# States we can transition to from this one
@export var idle_state: State
@export var walk_state: State
@export var ledge_grab_state: State

func enter() -> void:
	super()

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * max_speed
	parent.velocity.y += gravity * delta
	parent.velocity.x = movement
	if movement != 0:
		flip_animation_and_raycast(movement < 0)
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if movement != 0:
			return walk_state
		return idle_state
	
	if near_ledge():
		return ledge_grab_state
	
	return null
