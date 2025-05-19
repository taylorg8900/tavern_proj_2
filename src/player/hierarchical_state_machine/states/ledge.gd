extends State


func Enter() -> void:
	super()
	core.SnapToLedge()
	core.body.velocity = Vector2(0, 0)

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	pass


func DoPhysics(delta : float) -> void:
	pass
