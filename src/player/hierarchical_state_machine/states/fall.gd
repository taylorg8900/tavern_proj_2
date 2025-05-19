extends State

@export var terminal_velocity: float = 280
@export_range(16, 160, .5) var jump_height : float = 40
@export_range(0, 1, .01) var peak_time_to_ground : float = .35

@onready var fast_gravity : float = (2.0 * jump_height) / (peak_time_to_ground * peak_time_to_ground)


func Enter() -> void:
	core.body.velocity.y = 0
	super()

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	if core.input.x != 0:
		core.FlipDirectionFacing(core.input.x < 0)
	
func DoPhysics(delta : float) -> void:
	# update our y velocity
	core.body.velocity.y = move_toward(core.body.velocity.y, terminal_velocity, fast_gravity * delta)
	core.body.velocity.x = core.UpdateXVelocity(core.body.velocity.x, max_speed, core.input.x, acceleration, deceleration, delta)
	
	
