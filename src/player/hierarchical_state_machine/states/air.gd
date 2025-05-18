extends State

@export var jump : State
@export var fall : State

func Enter() -> void:
	super()

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	if Input.is_action_just_pressed('jump'):
		state_machine.Set(jump)

func DoPhysics(delta : float) -> void:
	pass
