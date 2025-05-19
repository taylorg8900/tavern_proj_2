extends State

@export var idle : State
@export var move : State

func Enter() -> void:
	super()

func DoPhysics(delta : float) -> void:
	pass

func Do(delta : float) -> void:
	if core.input.x != 0 or core.body.velocity.x != 0:
		state_machine.Set(move, true)
	if core.input.x == 0 and core.body.velocity.x == 0:
		state_machine.Set(idle, true)

	#print(core.input)
	#print(core.body.velocity.x)


#Ground State stuff
#
#idle state : State
#move state : State
#
#func Enter():
	#do nothing here actually
	#maybe set y velocity to 0 (core.body.velocity.y = 0)
#
#func DoPhysics(delta : float) -> void:
	#pass
#
#func Do(delta : float) -> void:
	#if we have x input
		#Set(move, true)
	#else
		#Set(idle, true)
#```
