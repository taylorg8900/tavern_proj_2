extends State

@export_range(0, 100, .5) var climb_up_speed : float = 25
@export_range(0, 100, .5) var climb_down_speed : float = 40

func Enter() -> void:
	super()

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	pass

func DoPhysics(delta : float) -> void:
	# if we input into the wall, move up
	# if we input 'down', move down
	# if we have neither of these, slow down until 0
	
	if core.input.y > 0:
		core.body.velocity.y = move_toward(core.body.velocity.y, -1 * climb_up_speed, delta * acceleration)
	elif core.input.y < 0:
		core.body.velocity.y = move_toward(core.body.velocity.y, climb_down_speed, delta * acceleration)
	elif core.input.x == core.GetDirectionFacing():
		core.body.velocity.y = move_toward(core.body.velocity.y, -1 * climb_up_speed, delta * acceleration)
	else: 
		core.body.velocity.y = move_toward(core.body.velocity.y, 0, delta * deceleration)
