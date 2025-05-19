extends State

@export var jump_state : State
@export var fall_state : State

func Enter() -> void:
	super()
	core.body.velocity = Vector2(0, 0)
	state_machine.state = null

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	pass
	#if Input.is_action_just_pressed('jump'):
		#state_machine.Set(jump_state)

func DoPhysics(delta : float) -> void:
	pass
	#if core.input.x != 0:
		#if core.input.x != core.GetDirectionFacing():
			#core.FlipDirectionFacing(core.input.x < 0)
			#state_machine.Set(fall_state)
