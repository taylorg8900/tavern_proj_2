extends State

# States we can transition to from this one
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

@export var acceleration_mult: float = .5
@export var deceleration_mult: float = .5

 #float clampf(value: float, min: float, max: float)
#var speed = 42.1
#var a = clampf(speed, 1.0, 20.5) # a is 20.5
#
#speed = -10.0
#var b = clampf(speed, -1.0, 1.0) # b is -1.0

#func process_physics
	#if movement input
		#increase x velocity by acceleration * delta * max move speed
		#limit x velocity so it does not exceed max move speed
	#else if no movement input, but still x velocity
		#decrease x velocity by deceleration * delta * max move speed
	#else
		#idle state

func process_physics(delta: float) -> State:
	var movement = get_movement_input() * delta
	if movement:
		print("movement")
		parent.velocity.x += acceleration_mult * move_speed * movement
		if parent.velocity.x > 0:
			parent.velocity.x = clampf(parent.velocity.x, 0, move_speed)
		else:
			parent.velocity.x = clampf(parent.velocity.x, -1 * move_speed, 0)
	elif movement == 0 && parent.velocity.x != 0:
		print('slowing down')
		if parent.velocity.x > 0:
			parent.velocity.x -= deceleration_mult * delta * move_speed
		else:
			parent.velocity.x += deceleration_mult * delta * move_speed
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


	
