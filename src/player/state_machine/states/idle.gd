extends State

# States we can transition to from this one
@export var walk_state: State
@export var jump_state: State
@export var fall_state: State


func enter() -> void:
	super()
	parent.velocity.x = 0


func process_physics(delta: float) -> State:
	
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	if get_movement_input() != 0.0:
		return walk_state
	
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	if !parent.is_on_floor():
		return fall_state
	return null
