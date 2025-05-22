#extends CharacterBody2D
extends StateManagerCore

class_name PlayerStateManager

@onready var hand_position: Marker2D = $HandPosition
@onready var top_raycast: RayCast2D = $TopRayCast
@onready var wall_raycast: RayCast2D = $WallRayCast
@onready var floor_raycast: RayCast2D = $FloorRayCast
@onready var air_raycast: RayCast2D = $AirRayCast
@onready var corner_raycast: RayCast2D = $CornerRayCast
@onready var corner_raycast_idle : RayCast2D = $IdleCornerRayCast
@onready var corner_checker_raycast: RayCast2D = $CornerCheckerRayCast
@onready var corner_checker_raycast_idle : RayCast2D = $IdleCornerCheckerRayCast

@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var coyote_time_timer : Timer = $CoyoteTimer
#@onready var wall_timer : Timer = $WallTimer

@onready var wall_timer : float

@export_range(0, 1, 0.01) var jump_buffer_time : float = .1
@export_range(0, 1, 0.01) var coyote_time : float = .12
@export_range(0, 1, 0.01) var wall_timer_time : float = .3
@export_range(0, 500, .5) var wall_speed_threshold : float = 100
@export_range(0, 500, .5) var ledge_speed_threshold : float = 300

@export var ground_state : State
@export var jump_state : State
@export var side_jump_state : State
@export var wall_jump : State
@export var fall_state : State
@export var wall_climb_state : State
@export var wall_slide_state : State
@export var ledge_state : State
@export var rope_state : State

var input : Vector2 = Vector2(0.0, 0.0)
var jump : bool = false
var crouch : bool = false

var on_ground : bool = false
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
	CheckInput()
	CheckBools()
	# SelectState() needs to be called here, because some of our logic requires updates from move_and_slide()
	# Having it in _process will be asking it to switch based on out of date information, which will cause inconsistent and weird transitions
	SelectState(delta)
	state_machine.state.DoPhysicsBranch(delta)
	ApplyCornerCorrection()
	body.move_and_slide()
	print(corner_raycast.target_position)


func _process(delta : float) -> void:
	
	state_machine.state.DoBranch(delta)
	#print(jump_buffer_timer.time_left)
	#print(state_machine.state.label_name)
	#print(near_rope)

func SelectState(delta : float) -> void:
	var state = state_machine.state
	
	if state == ground_state:
		if jump or CheckJumpBuffer():
			state_machine.Set(jump_state)
		if !on_ground:
			coyote_time_timer.start(coyote_time)
			state_machine.Set(fall_state)
		if near_rope:
			if input.y > 0:
				state_machine.Set(rope_state)
		if near_wall:
			# Use GetDirectionFacing so if we transition here from a wall_climb, we can walk away
			if input.x == GetDirectionFacing():
				# Using the built in Timer node and calling .start() will reset the timer every single time it is called, even though it isn't supposed to 
				# I could not find a solution to this, so I am just using a float to track our wall timer instead
				wall_timer -= delta
				if wall_timer < 0:
					state_machine.Set(wall_climb_state)
		else:
			ResetWallTimer()
	
	elif (state == jump_state) or (state == side_jump_state) or (state == wall_jump):
		ResetJumpBuffer()
		if jump:
			jump_buffer_timer.start()
		if on_ground:
			state_machine.Set(ground_state)
		if body.velocity.y > 0:
			state_machine.Set(fall_state)
		if near_wall:
			state_machine.Set(wall_climb_state)
		if near_rope:
			if input.y != 0 and !Input.is_action_pressed('jump'):
				state_machine.Set(rope_state)
	
	elif state == fall_state:
		ResetJumpBuffer()
		if jump:
			jump_buffer_timer.start()
		if on_ground:
			state_machine.Set(ground_state)
		if near_wall: 
			if body.velocity.y < wall_speed_threshold:
				if (state.parent_state != wall_climb_state) and (state.parent_state != ledge_state):
					state_machine.Set(wall_climb_state)
			else:
				if input.x != 0:
					state_machine.Set(wall_slide_state)
		if near_ledge:
			if body.velocity.y < ledge_speed_threshold:
				if state.parent_state != ledge_state:
					state_machine.Set(ledge_state)
		if jump and coyote_time_timer.time_left > 0:
			state_machine.Set(jump_state)
		if near_rope:
			if input.y != 0:
				state_machine.Set(rope_state)
	
	elif state == wall_climb_state:
		if on_ground:
			if input.y < 0 and input.x == 0:
				state_machine.Set(ground_state)
		if !near_wall or crouch:
			state_machine.Set(fall_state)
		if jump or CheckJumpBuffer():
			state_machine.Set(wall_jump)
		if near_ledge:
			# Avoids circular transitions if the player is holding both 'down' and 'side' simultaneously
			if (input.y > 0) or (input.x != 0 and input.y == 0):
				state_machine.Set(ledge_state)
	
	elif state == wall_slide_state:
		if on_ground:
			state_machine.Set(ground_state)
		if !near_wall:
			state_machine.Set(fall_state)
		if body.velocity.y == 0:
			state_machine.Set(wall_climb_state)
	
	elif state == ledge_state:
		if jump or CheckJumpBuffer():
			state_machine.Set(jump_state)
		if crouch:
			state_machine.Set(fall_state)
		if input.y < 0:
			state_machine.Set(wall_climb_state)
	
	elif state == rope_state:
		if on_ground and input.y < 0:
			state_machine.Set(ground_state)
		if jump:
			state_machine.Set(side_jump_state)
		if crouch:
			state_machine.Set(fall_state)
		if !near_rope:
			state_machine.Set(fall_state)
		

func CheckInput() -> void:
	input = Vector2(
		Input.get_axis('move_left', 'move_right'),
		Input.get_axis('down', 'up'))
	jump = Input.is_action_just_pressed('jump')
	crouch = Input.is_action_just_pressed('crouch')
	

func CheckGround() -> void:
	on_ground = body.is_on_floor()

func CheckLedge() -> void:
	near_ledge = !top_raycast.is_colliding() && wall_raycast.is_colliding()

func CheckWall() -> void:
	near_wall = wall_raycast.is_colliding()

func CheckRope() -> void:
	near_rope = !ropes.is_empty()

func CheckBools() -> void:
	CheckGround()
	CheckLedge()
	CheckWall()
	CheckRope()

func GetLedgeOffset() -> Vector2:
	var intersection = Vector2(wall_raycast.get_collision_point().x, air_raycast.get_collision_point().y)
	var target_pos = hand_position.global_position
	return intersection - hand_position.global_position

func SnapToLedge() -> void:
	body.position += GetLedgeOffset()

#have a raycast 2d shoot backwards from in front of the player with the same width as our hitbox
#if it is hitting a ceiling, find out where the global collision point was at
#subtract the collision point from our raycast's global position
#if the absolute value is less than our defined max, return the float
	#the float = raycast global pos - collision global pos
#add the float to our player position

func GetCeilingCornerCorrectionOffset() -> float:
	
	if corner_raycast.is_colliding():
		if !corner_checker_raycast.is_colliding():
			# We use GetDirectionFacing because target_position is not global, and I don't have it change it in the FlipDirectionFacing function
			var target_pos = corner_raycast.global_position.x + (corner_raycast.target_position.x * GetDirectionFacing())
			return corner_raycast.get_collision_point().x - target_pos
	elif corner_raycast_idle.is_colliding():
		if !corner_checker_raycast_idle.is_colliding():
			if input.x == 0:
				var target_pos = corner_raycast_idle.global_position.x + (corner_raycast_idle.target_position.x * GetDirectionFacing())
				return corner_raycast_idle.get_collision_point().x - target_pos
		pass
	return 0.0

func ApplyCornerCorrection() -> void:
	if body.velocity.y < 0:
		body.position.x += GetCeilingCornerCorrectionOffset()

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
		corner_raycast.position.x = -1 * abs(corner_raycast.position.x)
		corner_raycast.rotation_degrees = 180
		corner_raycast_idle.position.x = abs(corner_raycast.position.x)
		corner_raycast_idle.rotation_degrees = 180
		corner_checker_raycast.position.x = -1 * abs(corner_checker_raycast.position.x)
		corner_checker_raycast_idle.position.x = abs(corner_checker_raycast.position.x)

	else:
		top_raycast.rotation_degrees = 0
		wall_raycast.rotation_degrees = 0
		air_raycast.position.x = abs(air_raycast.position.x)
		hand_position.position.x = abs(hand_position.position.x)
		corner_raycast.position.x = abs(corner_raycast.position.x)
		corner_raycast.rotation_degrees = 0
		corner_raycast_idle.position.x = -1 * abs(corner_raycast_idle.position.x)
		corner_raycast_idle.rotation_degrees = 0
		corner_checker_raycast.position.x = abs(corner_checker_raycast.position.x)
		corner_checker_raycast_idle.position.x = -1 * abs(corner_checker_raycast.position.x)

func FlipRaycastPosition(raycast : RayCast2D) -> void:
	pass

func ResetCoyoteTimer(time : float = coyote_time) -> void:
	coyote_time_timer.stop()
	coyote_time_timer.set_wait_time(time)

func ResetJumpBuffer(time : float = jump_buffer_time) -> void:
	# Restart the jump buffer, if it is not already active
	if jump_buffer_timer.is_stopped():
		jump_buffer_timer.set_wait_time(time)

func ResetWallTimer(time : float = wall_timer_time) -> void:
	wall_timer = wall_timer_time

func CheckCoyoteTime() -> bool:
	return coyote_time_timer.time_left > 0

func CheckJumpBuffer() -> bool:
	return jump_buffer_timer.time_left > 0

#func CheckWallTimer() -> bool:
	#return wall_timer.time_left > 0

func EnterRope(node_entered: Node, rope: Node2D, x_pos: int) -> void:
	if node_entered is PlayerStateManager:
		near_rope = true
		ropes.append(rope.get_instance_id())
		rope_pos = x_pos

func ExitRope(node_entered: Node, rope: Node2D) -> void:
	if node_entered is PlayerStateManager:
		ropes.erase(rope.get_instance_id())

func UpdateXVelocity(current_vel : float, max_speed : int, direction : int, acceleration : float, deceleration : float, delta : float):
	if direction != 0:
		return move_toward(current_vel, max_speed * direction, acceleration * delta)
	return move_toward(current_vel, 0, deceleration * delta)





func CornerCorrection(delta : float, pixel_amount : int) -> void:
	 #If we are jumping, and we are going to hit a ceiling on the next frame
	if body.velocity.y < 0 and body.test_move(body.global_transform, Vector2(0, body.velocity.y * delta)):
		# Test for a number of pixels left and right 
		# If we won't hit the ceiling, move the player over
		for pixel in range(1, pixel_amount + 1):
			for direction in [-1, 1]:
				if !body.test_move(body.global_transform.translated(Vector2(pixel * direction, 0)), Vector2(0, body.velocity.y * delta)):
					body.position.x = (body.position.x + (pixel * direction))
					#body.position.y -= body.velocity.y * delta
					return
