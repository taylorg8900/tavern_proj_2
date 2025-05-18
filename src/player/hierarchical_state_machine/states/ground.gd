extends State

@export var idle : State
@export var move : State

func DoPhysics(delta : float) -> void:
	pass

func Do(delta : float) -> void:
	pass
	if core.input.x == 0:
		state_machine.Set(idle)

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
