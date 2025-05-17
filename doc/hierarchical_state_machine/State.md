What would my State class look like now that I have separated a lot of it's functionality and given it to PlayerStateManager?
```
@export var animation_name : string

var is_done : bool

var parent_state: State
var core : StateManagerCore
var state_machine : StateMachine
	- This has to be different than the one that StateManagerCore has because every single state within our scene will point to the same one otherwise, and each state wouldn't have it's own machine :(

func Enter() -> void:
	state_core.animations.play(animation_name)
func Exit() -> void:
func Do(delta : float) -> void:
func DoPhysics(delta : float) -> void:

func DoBranch(delta : float) -> void:
	Do(delta)
	state_machine.state.DoBranch(delta)

func DoPhysicsBranch(delta : float) -> void:
	DoPhysics(delta)
	state_machine.state.DoPhysics(delta)

func SetUpCore(core Core) -> void:
	# Called on creation of scene by our StateManagerCore, to get a reference to things like our AnimatedSprite2d
	state_core = core
	stae_machine = new StateMachine

func Initialise(state : State)
	# Called whenever we switch into this state from another one with Set()
	parent_state = state
	is_done = false
```
