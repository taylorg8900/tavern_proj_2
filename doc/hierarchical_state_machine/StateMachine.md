What would my StateMachine class look like?
```
class_name StateMachine

var state : State

func SetState(new_state: State, forcereset: bool = false)
	if new state != state or forcereset
		state.exit()
		new_state.Initialise(state) <- this might not work, i am trying to keep a reference to the original state within whichever state we enter for later
		state = new_state
		state.enter()
```
