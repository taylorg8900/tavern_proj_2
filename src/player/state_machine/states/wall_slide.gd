extends State

@export var idle_state: State
@export var fall_state: State
@export var wall_hang_state: State

@export var tile_pixel_size: int = 16
@export_range(0, 20, 0.5) var tile_slow_per_second: float = .5

@onready var wall_deceleration = tile_pixel_size * tile_slow_per_second

func enter() -> void:
	super()
	reset_jump_buffer_timer()


func process_physics(delta: float) -> State:
	parent.velocity.y = move_toward(parent.velocity.y, 0, wall_deceleration * delta)
	if parent.velocity.y == 0:
		return wall_hang_state
	
	if get_jump():
		jump_buffer_timer.start()
	
	parent.move_and_slide()
	
	if !near_wall():
		return fall_state
	
	if parent.is_on_floor():
		return idle_state
	
	return null
