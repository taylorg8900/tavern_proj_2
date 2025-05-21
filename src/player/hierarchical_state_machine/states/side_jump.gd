extends State

# jump height multiplier keeps the value for gravity the same as with regular jumping, but just modifies how high up we go
@export_range(0, 1, .05) var jump_height_multiplier = .6
@export_range(16, 160, .5) var jump_height : float = 40
@export_range(0, 1, .01) var jump_time_to_peak : float = .4
@export_range(0, 1, .01) var peak_time_to_ground : float = .35

@onready var jump_velocity : float = (-2.0 * jump_height) / jump_time_to_peak
@onready var fast_gravity : float = (2.0 * jump_height) / (peak_time_to_ground * peak_time_to_ground)
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)

var switch_to_fast_gravity : bool = false


func Enter() -> void:
	super()
	core.body.velocity = Vector2(max_speed * core.GetDirectionFacing(), jump_velocity * jump_height_multiplier)
	core.FlipDirectionFacing(core.body.velocity.x < 0)
	switch_to_fast_gravity = false
	

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	if !Input.is_action_pressed('jump'):
		switch_to_fast_gravity = true


func DoPhysics(delta : float) -> void:
	if switch_to_fast_gravity:
		core.body.velocity.y += fast_gravity * delta
	else:
		core.body.velocity.y += jump_gravity * delta
