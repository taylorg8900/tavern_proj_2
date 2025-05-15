extends State

#@export_range(min, max, step value) var health
# States we can transition to from this one
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State
@export var rope_state: State
@export var climb_state: State

@export_range(0, 1, .05) var time_to_enter_climb: float = .25

@onready var climb_timer: float

func enter() -> void:
	super()
	climb_timer = time_to_enter_climb
	reset_coyote_time()


func process_physics(delta: float) -> State:
	
	# Keep this before idle state check, or it will always enter idle state
	change_velocity_x(delta) 
	
	if parent.velocity.x == 0:
		return idle_state
		
	# if this is after move_and_slide, small values will get rounded to 0 and flip_h gets called before we enter idle state in the next process
	flip_animation_and_raycast(parent.velocity.x < 0)
	
	if parent.is_on_floor():
		if get_jump() or get_jump_buffer_timer():
			return jump_state
	else:
		return fall_state
	
	if near_wall():
		climb_timer -= delta
		if climb_timer <= 0:
			return climb_state
	else: 
		climb_timer = time_to_enter_climb
	
	if near_rope && Input.is_action_pressed('up'):
		return rope_state
	
	
	parent.velocity.y += gravity * delta
	parent.move_and_slide()
	return null
