extends State

#@export_range(min, max, step value) var health
# States we can transition to from this one
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State
@export var rope_state: State
@export var climb_state: State

@export_range(0, 1, .05) var time_to_enter_climb: float = .5

@onready var timer: float

func enter() -> void:
	super()
	acceleration = max_speed / seconds_to_reach_max_speed
	deceleration = max_speed / seconds_to_reach_zero_speed
	timer = time_to_enter_climb

func process_physics(delta: float) -> State:
	change_velocity_x(delta)
	
	if parent.velocity.x == 0:
		return idle_state
		
	# if this is after move_and_slide, small values will get rounded to 0 and flip_h gets called before we enter idle state in the next process
	flip_animation_and_raycast(parent.velocity.x < 0)
	
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	
	if get_jump() and parent.is_on_floor():
		return jump_state
	
	if !parent.is_on_floor():
		return fall_state
		
	if near_wall():
		timer -= delta
	else: 
		timer = time_to_enter_climb
	
	if timer <= 0:
		return climb_state
	
	if near_rope && Input.is_action_pressed('up'):
		return rope_state
	
	return null
