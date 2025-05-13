extends AirState

@export var fall_state: State
@export var wall_slide: State
@export var wall_climb: State
@export var ledge_hang: State

@onready var jump_velocity : float = (-2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)

var switch_to_fast_gravity : bool = false

func enter() -> void:
	super()
	parent.velocity.y = jump_velocity
	switch_to_fast_gravity = false

func process_physics(delta: float) -> State: 
	return null
