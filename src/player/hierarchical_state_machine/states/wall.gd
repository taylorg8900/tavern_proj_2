extends State

@export var ledge_state : State
@export var climb_state : State
@export var slide_state : State

func Enter() -> void:
	super()

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	pass


func DoPhysics(delta : float) -> void:
	if core.near_ledge:
		state_machine.Set(ledge_state)
	else:
		state_machine.Set(climb_state)
	pass
