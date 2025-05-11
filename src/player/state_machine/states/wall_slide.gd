extends State

@export var idle_state: State
@export var drop_state: State
@export var wall_hang_state: State

@export var tile_pixel_size: int = 16
@export_range(0, 20, 0.5) var tile_slow_per_second: float = .5

@onready var wall_deceleration = tile_pixel_size * tile_slow_per_second

func enter() -> void:
	super()

#deceleration = tile size * how many tiles to slow down per second by
#
#func physics_process()
	#slow down y velocity by deceleration amount * delta
	#if y velocity == 0
		#enter wall hang state
	#if movement input not equal to direction we are facing
		#flip animations and raycasts
		#enter drop state

func process_physics(delta: float) -> State:
	parent.velocity.y = move_toward(parent.velocity.y, 0, wall_deceleration * delta)
	if parent.velocity.y == 0:
		return wall_hang_state

	if get_movement_input() != 0:
		if get_movement_input() != get_direction():
			flip_animation_and_raycast(get_movement_input() < 0)
			return drop_state
	
	parent.move_and_slide()
	
	if parent.is_on_floor():
		return idle_state
	
	return null
