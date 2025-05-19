extends State

@export var tile_pixel_size: int = 16
@export_range(0, 20, 0.5) var tile_slow_per_second: float = .5

@onready var wall_deceleration = tile_pixel_size * tile_slow_per_second

func Enter() -> void:
	super()

func Exit() -> void:
	pass

func Do(delta : float) -> void:
	pass

func DoPhysics(delta : float) -> void:
	core.body.velocity.y = move_toward(core.body.velocity.y, 0, wall_deceleration * delta)
