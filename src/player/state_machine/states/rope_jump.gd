extends "res://src/player/state_machine/states/wall_jump.gd"

func enter() -> void:
	super()
	# This flips our direction back from what 'wall_jump' set it to
	flip_animation_and_raycast(parent.velocity.x > 0)
	parent.velocity = Vector2(max_speed * get_direction(), jump_velocity)
	flip_animation_and_raycast(parent.velocity.x < 0)

func process_physics(delta: float) -> State:
	return super(delta)
