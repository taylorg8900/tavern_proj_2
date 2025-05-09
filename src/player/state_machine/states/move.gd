extends State

#@export_range(min, max, step value) var health
# States we can transition to from this one
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

@export var acceleration_mult: float = .5
@export var deceleration_mult: float = .5

#@export_range(0, 1, .01) var acceleration_mult: float = .5




#func process_physics
	#if movement input
		#increase x velocity by acceleration * delta * max move speed
		#limit x velocity so it does not exceed max move speed
	#else if no movement input, but still x velocity
		#decrease x velocity by deceleration * delta * max move speed
	#else
		#idle state

#float move_toward(from: float, to: float, delta: float)
#move_toward(5, 10, 4)    # Returns 9
#move_toward(10, 5, 4)    # Returns 6
#move_toward(5, 10, 9)    # Returns 10
#move_toward(10, 5, -1.5) # Returns 11.5

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * delta
	var acceleration = acceleration_mult * max_speed
	if movement:
		print("movement")
		# from current velocity towards max velocity * movement input direction, by move speed * acceleration * delta
		parent.velocity.x = move_toward(parent.velocity.x, get_movement_input() * max_speed, max_speed * acceleration * delta)
	elif movement == 0 && parent.velocity.x != 0:
		print('slowing down')
		if parent.velocity.x > 0:
			parent.velocity.x -= deceleration_mult * delta * max_speed
		else:
			parent.velocity.x += deceleration_mult * delta * max_speed
	else:
		return idle_state
	
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	# Put this after the idle_state check so the player model doesn't flip back on accident
	animations.flip_h = parent.velocity.x < 0
	
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	if !parent.is_on_floor():
		return fall_state
	return null


	
