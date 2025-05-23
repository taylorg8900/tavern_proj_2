class_name AirState
extends State

@export var terminal_velocity: float = 280
@export_range(16, 160, .5) var jump_height : float = 40
@export_range(0, 1, .01) var jump_time_to_peak : float = .4
@export_range(0, 1, .01) var peak_time_to_ground : float = .35

@onready var jump_velocity : float = (-2.0 * jump_height) / jump_time_to_peak
@onready var fast_gravity : float = (2.0 * jump_height) / (peak_time_to_ground * peak_time_to_ground)
@onready var jump_gravity : float = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
