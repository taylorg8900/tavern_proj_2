extends State

@export_range(0, 100, .5) var climb_speed : float = 50

func Enter() -> void:
	core.body.position.x = core.rope_pos
	core.body.velocity.x = 0
	super()

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	if core.input.x != 0:
		core.FlipDirectionFacing(core.input.x < 0)

func DoPhysics(delta : float) -> void:
	if core.input.y > 0:
		core.body.velocity.y = move_toward(core.body.velocity.y, -1 * climb_speed, delta * acceleration)
	elif core.input.y < 0:
		core.body.velocity.y = move_toward(core.body.velocity.y, climb_speed, delta * acceleration)
	else:
		core.body.velocity.y = move_toward(core.body.velocity.y, 0, delta * deceleration)
