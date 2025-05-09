extends State

# States we can transition to from this one
@export var idle_state : State
#@export var sprint_state : State
#@export var jump_state : State
@export var fall_state : State

func enter() -> void:
	super()

func process_input(event: InputEvent) -> State:
	if get_movement_input() == 0.0:
		return idle_state
	return null

func process_physics(delta: float) -> State:
	parent.velocity.x = move_speed
	return null
