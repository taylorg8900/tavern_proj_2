extends State

# States we can transition to from this one
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

@export var acceleration_mult: float = .5
@export var deceleration_mult: float = .5

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * move_speed
	parent.velocity.y += gravity * delta
	var x_velocity = movement * acceleration_mult * delta
	parent.velocity.x += clamp(0, move_speed, x_velocity)
	parent.move_and_slide()
	
	if parent.velocity.x == 0:
		return idle_state
	
	# Put this after the idle_state check so the player model doesn't flip back on accident
	animations.flip_h = parent.velocity.x < 0
	
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	if !parent.is_on_floor():
		return fall_state
	return null


	
