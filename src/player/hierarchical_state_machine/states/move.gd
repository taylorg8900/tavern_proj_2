extends State

func Enter() -> void:
	super()


func DoPhysics(delta : float) -> void:
	core.body.velocity.x = core.UpdateXVelocity(core.body.velocity.x, max_speed, core.input.x, acceleration, deceleration, delta)
	if core.input.x != 0:
		core.FlipDirectionFacing(core.body.velocity.x < 0)

func Do(delta : float) -> void:
	pass
