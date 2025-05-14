extends AirState

@export var idle_state: State
@export var move_state: State
@export var rope_climb_state: State
@export var wall_slide_state: State
@export var wall_climb_state: State
@export var ledge_hang_state: State

# since changing the jump height in the inspector will change our value for gravity, i have this instead
@export_range(0, 1, .05) var jump_height_multiplier = .6

@onready var jump_velocity : float = jump_height_multiplier * (-2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)

@onready var switch_to_fast_gravity : bool = false

func enter() -> void:
	super()
	parent.velocity = Vector2(max_speed * get_direction() * -1, jump_velocity)
	flip_animation_and_raycast(parent.velocity.x < 0)
	switch_to_fast_gravity = false

func process_physics(delta: float) -> State:
	if get_movement_input() != 0:
		change_velocity_x(delta)
		# having this isolated will cause the animations to flip if somehow we hit a wall without triggering near_wall or near_ledge, so keep it up here
		flip_animation_and_raycast(parent.velocity.x < 0)
	
	if near_ledge():
		snap_to_ledge()
		return ledge_hang_state
	
	if switch_to_fast_gravity:
		parent.velocity.y += fast_gravity * delta
	else:
		parent.velocity.y += jump_gravity * delta
	
	if near_wall():
		if parent.velocity.y < 0:
			return wall_climb_state
		return wall_slide_state
	
	if parent.is_on_floor():
		if get_movement_input() != 0:
			return move_state
		return idle_state
	
	if near_rope && Input.is_action_pressed('up'):
		return rope_climb_state
	
	parent.move_and_slide()
	
	if !Input.is_action_pressed("jump"):
		switch_to_fast_gravity = true
	
	return null
