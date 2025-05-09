extends State

# States we can transition to from this one
@export var fall_state: State
@export var idle_state: State
@export var walk_state: State
@export var jump_state: State

@export var sprint_mult: int = 1.5

func enter() -> void:
	super()

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * move_speed * sprint_mult
	parent.velocity.x = movement
	parent.velocity.y += gravity * delta
	animations.flip_h = movement < 0
	
	parent.move_and_slide()
	
	if movement == 0:
		return idle_state
	
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	if !parent.is_on_floor():
		return fall_state
	return null
