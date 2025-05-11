class_name AirState
extends State

@export var terminal_velocity: float = 320
@export var jump_height : float = 30
@export_range(0, 1, .01) var jump_time_to_peak : float = .4
@export_range(0, 1, .01) var peak_time_to_ground : float = .25

@onready var fast_gravity : float = (2.0 * jump_height) / (peak_time_to_ground * peak_time_to_ground)
