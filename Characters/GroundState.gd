extends State

class_name GroundState

@export var jump_velocity : float = -250.0
@export var air_state : State
@export var ground_deceleration : float

var just_jumped: bool = false

func on_enter():
	just_jumped = false
	if (character.is_quickfalling):
		character.is_quickfalling = false
		character.move_lock = false
	if (character.has_jump_buffer) and (character.jump_held):
		jump()

func state_input(event : InputEvent):
	if (event.is_action_pressed("jump")):
		if !(character.is_dashing):
			jump()
		else: character.buffer_jump
	if (event.is_action_pressed("dash")) and (character.can_dash):
		dash()
	if (event.is_action_pressed("crouch")):
		if character.direction.x != 0:
			print("slide")
		else:
			print("crouch")

func state_process(delta):
	if (!character.is_on_floor()):
		next_state = air_state
	elif !(character.is_dashing):
		if character.direction.x != 0:
			character.velocity.x = character.speed * character.direction.x
		else:
			character.velocity.x = move_toward(character.velocity.x, 0, ground_deceleration)

func dash():
	character.start_dash_timer()

func jump():
	just_jumped = true
	character.velocity.y = jump_velocity

func on_exit():
	if (next_state == air_state) and !(just_jumped):
		character.start_coyote_time()
