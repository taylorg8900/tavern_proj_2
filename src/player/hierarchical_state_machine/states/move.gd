extends State

func Enter() -> void:
	super()
	
func DoPhysics(delta : float) -> void:
	if core.input.x != 0:
		core.body.velocity.x = move_toward(core.body.velocity.x, max_speed * core.input.x, delta * acceleration)
	else:
		core.body.velocity.x = move_toward(core.body.velocity.x, 0, delta * deceleration)

func Do(delta : float) -> void:
	core.FlipDirectionFacing(core.body.velocity.x < 0)
	pass
