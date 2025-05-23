extends Node

@onready var default_states = $DefaultStates
@onready var wall_states = $WallStates
@onready var ledge_states = $LedgeStates

@onready var states_categories = [default_states, wall_states, ledge_states]

@export var starting_state: State

var current_state: State

# Initialize the state machine by giving each child state a reference to the
# parent object it belongs to and enter the default starting_state.
func init(parent: CharacterBody2D, animations: AnimatedSprite2D, label: Label, hand_position: Marker2D, top_raycast: RayCast2D, wall_raycast: RayCast2D, floor_raycast: RayCast2D, air_raycast: RayCast2D, jump_buffer_timer: Timer) -> void:
	for category in states_categories:
		for child in category.get_children():
			child.parent = parent
			child.animations = animations
			child.label = label
			child.hand_position = hand_position
			child.top_raycast = top_raycast
			child.wall_raycast = wall_raycast
			child.floor_raycast = floor_raycast
			child.air_raycast = air_raycast
			child.jump_buffer_timer = jump_buffer_timer

	# Initialize to the default state
	change_state(starting_state)

# Change to the new state by first calling any exit logic on the current state.
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()
	
# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)

func process_input(event: InputEvent) -> void:
	var new_state = current_state.process_input(event)
	if new_state:
		change_state(new_state)

func process_frame(delta: float) -> void:
	var new_state = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
