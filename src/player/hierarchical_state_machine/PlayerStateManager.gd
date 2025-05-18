extends StateManagerCore

@onready var hand_position: Marker2D = $HandPosition
@onready var top_raycast: RayCast2D = $TopRayCast
@onready var wall_raycast: RayCast2D = $WallRayCast
@onready var floor_raycast: RayCast2D = $FloorRayCast
@onready var air_raycast: RayCast2D = $AirRayCast
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_time_timer : Timer = $CoyoteTimer

@export_range(0, 1, 0.01) var jump_buffer_time : float
@export_range(0, 1, 0.01) var coyote_time : float

@export var ground_state : State

var input : Vector2 = Vector2(0.0, 0.0)
var on_ground : bool = false
var in_air : bool = false
var near_ledge : bool = false
var near_wall : bool = false
var near_rope : bool = false

var ropes : Array
var rope_pos : int

func _ready() -> void:
	Signals.rope_entered.connect(EnterRope)
	Signals.rope_exited.connect(ExitRope)
	SetUpStates(self)
	state_machine.Set(ground_state)

func _physics_process(delta: float) -> void:
	CheckBools()
#_physics_process(delta: float)
	#check all of our bools up there in here
	#call Do() on our current state
#
#_process(delta: float)
	#update input with GetInput()
	#check our jump buffer or coyote time in here
#

func GetInput() -> void:
	input = Vector2(
		Input.get_axis('move_left', 'move_right'),
		Input.get_axis('up', 'down'))
	

func CheckGround() -> void:
	on_ground = body.is_on_floor()

func CheckAir() -> void:
	in_air = !body.is_on_floor()

func CheckLedge() -> void:
	near_ledge = !top_raycast.is_colliding() && wall_raycast.is_colliding()

func CheckWall() -> void:
	near_wall = wall_raycast.is_colliding()

func CheckRope() -> void:
	near_rope = !ropes.is_empty()

func CheckBools() -> void:
	CheckGround()
	CheckAir()
	CheckLedge()
	CheckWall()
	CheckRope()

func SnapToLedge() -> void:
	body.position += GetLedgeOffset()

func GetLedgeOffset() -> Vector2:
	var intersection = Vector2(wall_raycast.get_collision_point().x, air_raycast.get_collision_point().y)
	var target_pos = hand_position.global_position
	return intersection - hand_position.global_position

func GetDirectionFacing() -> int:
	if animation.flip_h:
		return -1
	return 1

func FlipDirectionFacing(flip : bool) -> void:
	animation.flip_h = flip
	if flip:
		top_raycast.rotation_degrees = 180
		wall_raycast.rotation_degrees = 180
		air_raycast.position.x = -1 * abs(air_raycast.position.x)
		hand_position.position.x = -1 * abs(hand_position.position.x)
	else:
		top_raycast.rotation_degrees = 0
		wall_raycast.rotation_degrees = 0
		air_raycast.position.x = abs(air_raycast.position.x)
		hand_position.position.x = abs(hand_position.position.x)

func ResetCoyoteTimer(time : float = coyote_time) -> void:
	coyote_time_timer.stop()
	coyote_time_timer.set_wait_time(time)

func ResetJumpBuffer(time : float = jump_buffer_time) -> void:
	if jump_buffer_timer.is_stopped():
		jump_buffer_timer.stop()
		jump_buffer_timer.set_wait_time(time)

func EnterRope(node_entered: Node2D, rope: Node2D, x_pos: int) -> void:
	if node_entered is Player:
		near_rope = true
		ropes.append(rope.get_instance_id())
		rope_pos = x_pos

func ExitRope(node_entered: Node2D, rope: Node2D) -> void:
	if node_entered is Player:
		ropes.erase(rope.get_instance_id())
