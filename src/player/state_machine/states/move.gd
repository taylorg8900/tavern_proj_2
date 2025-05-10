extends State

#@export_range(min, max, step value) var health
# States we can transition to from this one
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

@export_range(0, 1, 0.01) var seconds_to_reach_max_speed: float
@export_range(0, 1, 0.01) var seconds_to_reach_zero_speed: float

var acceleration
var deceleration


func enter() -> void:
	super()
	acceleration = max_speed / seconds_to_reach_max_speed
	deceleration = max_speed / seconds_to_reach_zero_speed

func process_physics(delta: float) -> State:
	if get_movement_input() != 0:
		parent.velocity.x = move_toward(parent.velocity.x, get_movement_input() * max_speed, acceleration * delta)
	elif get_movement_input() == 0:
		parent.velocity.x = move_toward(parent.velocity.x, 0, deceleration * delta)
	
	if parent.velocity.x == 0:
		return idle_state
		
	# if this is after move_and_slide, small values will get rounded to 0 and flip_h gets called before we enter idle state in the next process
	flip_animation_and_raycast(parent.velocity.x < 0)
	
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	if !parent.is_on_floor():
		return fall_state
	return null
