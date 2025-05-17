What would my State class look like now that I have separated a lot of it's functionality and given it to PlayerStateManager?
```
var is_done : bool

var state_core : StateManagerCore

func Enter() -> void:
func Exit() -> void:
func Do() -> void:
func DoPhysics() -> void:

func DoBranch() -> void:
	Do()
	state_core.state_machine.DoBranch()

```
