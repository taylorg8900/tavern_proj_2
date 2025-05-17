What would my StateMachine class look like?
```
class_name StateMachine

var state : State

function to compare a given State to state, and call exit() and all that and enter new state yada yada
func SetState(new_state: State, forcereset: bool = false)
	if new state != state or forcereset
		state.exit
		state = new_state
		state.enter
```
