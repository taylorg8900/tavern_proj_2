extends "res://src/player/state_machine/states/wall_jump.gd"

func enter() -> void:
	super()
	parent.velocity = Vector2(max_speed * get_direction(), jump_velocity)
	flip_animation_and_raycast(parent.velocity.x < 0)
	switch_to_fast_gravity = false
