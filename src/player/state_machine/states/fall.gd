extends State

# States we can transition to from this one
@export var idle_state: State
@export var walk_state: State

func enter() -> void:
	super()

func process_physics(delta: float) -> State:
	parent.velocity.y += gravity * delta

	var movement = get_movement_input() * move_speed
	
	if movement != 0:
		animations.flip_h = movement < 0
	parent.velocity.x = movement
	parent.move_and_slide()
	
	if parent.is_on_floor():
		if movement != 0:
			return walk_state
		return idle_state
	return null
