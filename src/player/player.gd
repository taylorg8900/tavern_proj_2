class_name Player
extends CharacterBody2D

@onready var movement_animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var movement_state_machine: Node = $state_machine
@onready var label: Label = $Label
@onready var top_raycast: RayCast2D = $TopRayCast
@onready var bottom_raycast: RayCast2D = $BottomRayCast

func _ready() -> void:
	movement_state_machine.init(self, movement_animations, label, top_raycast, bottom_raycast)

func _unhandled_input(event: InputEvent) -> void:
	movement_state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	movement_state_machine.process_physics(delta)

func _process(delta: float) -> void:
	movement_state_machine.process_frame(delta)
