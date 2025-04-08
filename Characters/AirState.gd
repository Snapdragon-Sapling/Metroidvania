extends State

class_name AirState

@export var double_jump_velocity : float = -200
@export var air_resistance : float
@export var ground_state : State
@export var wall_state : State
var has_double_jumped : bool = false
var can_airdash: bool = true

func state_process(delta):
	if character.is_on_floor():
		next_state = ground_state
	elif character.wall_raycast.is_colliding():
		next_state = wall_state
	else:
		if (character.move_lock == false):
			if (character.direction.x != 0):
				character.velocity.x = character.direction.x * character.speed
			else:
				character.velocity.x = move_toward(character.velocity.x, 0, air_resistance)
		if (character.is_dashing == true):
			character.velocity.y = 0
		elif (character.velocity.y in range(-20, 20)) and !(character.is_quickfalling):
			character.velocity.y += 20 * delta
		elif !(character.is_quickfalling):
			character.velocity.y = min(character.velocity.y + character.gravity * delta, character.max_fall_speed)


func state_input(event : InputEvent):
	if (event.is_action_pressed("jump")):
		if (character.has_coyote_time) and !(character.is_dashing):
			ground_state.jump()
		elif !(has_double_jumped) and !(character.is_dashing):
			double_jump()
		else:
			character.buffer_jump()
	if (event.is_action_released("jump")) and !(has_double_jumped):
		if character.velocity.y < 0:
			character.velocity.y = (character.velocity.y * 0.5)
	if (event.is_action_pressed("dash")) and (character.can_dash) and (can_airdash):
		airdash()
	if (event.is_action_pressed("crouch")):
		character.quickfall()

func double_jump():
	character.velocity.y = double_jump_velocity
	has_double_jumped = true

func airdash():
	character.start_dash_timer()
	can_airdash = false

func on_exit():
	if (next_state == ground_state) or (next_state == wall_state):
		has_double_jumped = false
	can_airdash = true



