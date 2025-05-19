extends StateManagerCore

@onready var hand_position: Marker2D = $HandPosition
@onready var top_raycast: RayCast2D = $TopRayCast
@onready var wall_raycast: RayCast2D = $WallRayCast
@onready var floor_raycast: RayCast2D = $FloorRayCast
@onready var air_raycast: RayCast2D = $AirRayCast
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_time_timer : Timer = $CoyoteTimer

@export_range(0, 1, 0.01) var jump_buffer_time : float = .1
@export_range(0, 1, 0.01) var coyote_time : float = .12

@export var ground_state : State
@export var jump_state : State
@export var fall_state : State
@export var wall_state : State

var input : Vector2 = Vector2(0.0, 0.0)
var jump : bool = false
var crouch : bool = false

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
	# SelectState() needs to be called here, because some of our logic requires updates from move_and_slide()
	# Having it in _process will be asking it to switch based on out of date information, which will cause inconsistent and weird transitions
	SelectState()
	state_machine.state.DoPhysicsBranch(delta)
	body.move_and_slide()
	print(state_machine.state.label_name)

func _process(delta : float) -> void:
	CheckInput()
	state_machine.state.DoBranch(delta)

func SelectState() -> void:
	if on_ground:
		if CheckJumpBuffer():
			state_machine.Set(jump_state)
		else:
			state_machine.Set(ground_state)
	if Input.is_action_just_pressed('jump'):
		if (state_machine.state == ground_state) or (CheckCoyoteTime()):
			state_machine.Set(jump_state)
	if near_wall:
		state_machine.Set(wall_state)
	if in_air:
		if state_machine.state == ground_state:
			ResetCoyoteTimer(coyote_time)
			coyote_time_timer.start()
			state_machine.Set(fall_state)
		if (state_machine.state == jump_state) and (body.velocity.y > 0):
			state_machine.Set(fall_state)
	

func CheckInput() -> void:
	input = Vector2(
		Input.get_axis('move_left', 'move_right'),
		Input.get_axis('down', 'up'))
	jump = Input.is_action_pressed('jump')
	crouch = Input.is_action_pressed('crouch')
	

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

func CheckCoyoteTime() -> bool:
	return coyote_time_timer.time_left > 0

func CheckJumpBuffer() -> bool:
	return jump_buffer_timer.time_left > 0

func EnterRope(node_entered: Node2D, rope: Node2D, x_pos: int) -> void:
	if node_entered is Player:
		near_rope = true
		ropes.append(rope.get_instance_id())
		rope_pos = x_pos

func ExitRope(node_entered: Node2D, rope: Node2D) -> void:
	if node_entered is Player:
		ropes.erase(rope.get_instance_id())

func UpdateXVelocity(current_vel : float, max_speed : int, direction : int, acceleration : float, deceleration : float, delta : float):
	if direction != 0:
		return move_toward(current_vel, max_speed * direction, acceleration * delta)
	return move_toward(current_vel, 0, deceleration * delta)
