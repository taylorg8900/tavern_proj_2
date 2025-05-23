extends Node

class_name StateMachine

var state : State

func Set(new_state : State, forcereset : bool = false) -> void:
	if (new_state != state) or forcereset:
		if state != null:
			state.Exit()
		new_state.Initialise(state)
		state = new_state
		state.Enter()
