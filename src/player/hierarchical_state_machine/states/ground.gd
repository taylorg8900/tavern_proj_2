extends State

@export var idle : State
@export var move : State

func Enter() -> void:
	super()

func DoPhysics(delta : float) -> void:
	pass

func Do(delta : float) -> void:
	# Set move and idle forcereset to true, because Ground will remember the last time and won't transition to them in edge cases
	if core.input.x != 0 or core.body.velocity.x != 0:
		state_machine.Set(move, true)
	if core.input.x == 0 and core.body.velocity.x == 0:
		state_machine.Set(idle, true)
