extends State

@export var idle : State
@export var move : State

func DoPhysics(delta : float) -> void:
	pass

func Do(delta : float) -> void:
	if core.input.x == 0:
		print('yeah baby')
		state_machine.Set(idle)
	if Input.is_action_pressed('down'):
		print('yessir')

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
