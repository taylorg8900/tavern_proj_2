extends State

@export var ledge_grab_state : State
@export var drop_state : State

@export var climb_speed : int = 20

func enter() -> void:
	super()

#export var climbing speed
#
#func process phys
	#if player holding diagonally
		#y velocity = climbing speed, prob do some move towards stuff here just cuz
	#else
		#y velocity = 0
	#
	#move and slide (dunno if i need this tbh)
	#
	#if near ledge
		#enter ledge hang state
	#if movement input not equal to direction we are facing
		#enter drop state

func process_physics(delta: float) -> State:
	if get_movement_input() != 0:
	#if (get_movement_input() == get_direction()) or Input.is_action_pressed("jump"):
		parent.velocity.y = move_toward(parent.velocity.y, -1 * climb_speed, delta * acceleration)
	else:
		parent.velocity.y = move_toward(parent.velocity.y, 0, delta * deceleration)
		#parent.velocity.y = 0
	
	parent.move_and_slide()
	
	if near_ledge():
		return ledge_grab_state
	if get_movement_input() != 0:
		if get_movement_input() != get_direction():
			return drop_state
		
	return null
