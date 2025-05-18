extends State

func Enter() -> void:
	super()
	
func DoPhysics(delta : float) -> void:
	#core.body.velocity.x = move_toward(core.body.velocity.x, max_speed * core.input.x, delta * acceleration)
	print(core.input)
	core.body.position.x += max_speed

func Do(delta : float) -> void:
	pass
