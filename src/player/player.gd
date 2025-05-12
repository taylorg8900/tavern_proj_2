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

func _ready() -> void:
	movement_state_machine.init(self, movement_animations, label, hand_position, top_raycast, wall_raycast, floor_raycast, air_raycast)

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	movement_state_machine.process_physics(delta)

func _process(delta: float) -> void:
	movement_state_machine.process_frame(delta)
