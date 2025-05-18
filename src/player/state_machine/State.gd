class_name State
extends Node

@export var animation_name : String
@export var label_name : String

@export var max_speed : int = 100
@export_range(0, 1, 0.01) var seconds_to_reach_max_speed: float = .1
@export_range(0, 1, 0.01) var seconds_to_reach_zero_speed: float = .1

@onready var acceleration = max_speed / seconds_to_reach_max_speed
@onready var deceleration = max_speed / seconds_to_reach_zero_speed

var is_done : bool

var parent_state: State
var core : StateManagerCore
var state_machine : StateMachine

func Enter() -> void:
	core.animation.play(animation_name)
	core.label.set_text(label_name)

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	pass

func DoPhysics(delta : float) -> void:
	pass

func DoBranch(delta : float) -> void:
	Do(delta)
	if state_machine != null and state_machine.state != null:
		state_machine.state.DoBranch(delta)

func DoPhysicsBranch(delta : float) -> void:
	DoPhysics(delta)
	if state_machine != null and state_machine.state != null:
		state_machine.state.DoPhysicsBranch(delta)

func SetCore(state_core : StateManagerCore) -> void:
	# Called on creation of scene by our StateManagerCore, to get a reference to things like our AnimatedSprite2d
	state_machine = StateMachine.new()
	core = state_core

func Initialise(state : State) -> void:
	# Called whenever we switch into this state from another one with Set()
	parent_state = state
	is_done = false
