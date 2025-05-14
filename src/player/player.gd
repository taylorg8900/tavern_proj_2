class_name Player
extends CharacterBody2D

@onready var movement_animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_state_machine: Node = $StateMachine
@onready var label: Label = $Label
@onready var hand_position: Marker2D = $HandPosition
@onready var top_raycast: RayCast2D = $TopRayCast
@onready var wall_raycast: RayCast2D = $WallRayCast
@onready var floor_raycast: RayCast2D = $FloorRayCast
@onready var air_raycast: RayCast2D = $AirRayCast
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

func _ready() -> void:
	#Signals.rope_entered.connect(rope_grabbed)
	#Signals.rope_exited.connect(rope_exited)
	movement_state_machine.init(self, movement_animations, label, hand_position, top_raycast, wall_raycast, floor_raycast, air_raycast, jump_buffer_timer)

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	movement_state_machine.process_physics(delta)

func _process(delta: float) -> void:
	movement_state_machine.process_frame(delta)

#func rope_grabbed(x_pos: int) -> void:
	#print("entered rope at", x_pos)
#
#func rope_exited() -> void:
	#print("rope exited")
