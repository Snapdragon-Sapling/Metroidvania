extends State

class_name WallState

@export var air_state : State
@export var ground_state: State
@export var wall_slide_acceleration : float = 20
@export var max_wall_slide_speed: float = 100
@export var wall_jump_y : float = -250
@export var wall_jump_x : float = -150

#func on_enter():
	#if (character.has_jump_buffer == true) and (character.jump_held == true):
		#wall_jump()

func state_process(delta):
	if (character.move_lock == false):
		character.velocity.x = character.direction.x * character.speed
	if (character.is_on_floor()):
		next_state = ground_state
	elif (!character.wall_raycast.is_colliding()):
		next_state = air_state
	elif (character.is_dashing == true):
		character.velocity.y = 0
	elif (Input.is_action_pressed("left")) or (Input.is_action_pressed("right")):
		if character.velocity.y >= 0:
			character.is_wall_sliding = true
			character.velocity.y = min(character.velocity.y + wall_slide_acceleration * delta, max_wall_slide_speed)
		else:
			character.is_wall_sliding = false
			character.velocity.y = min(character.velocity.y + character.gravity * delta, character.max_fall_speed)
	elif !(character.is_quickfalling):
		character.is_wall_sliding = false
		character.velocity.y = min(character.velocity.y + character.gravity * delta, character.max_fall_speed)



func state_input(event : InputEvent):
	if (event.is_action_pressed("jump")) and !(character.is_dashing):
		wall_jump()
	if (event.is_action_pressed("dash")) and (character.can_dash):
		walldash()
	if (event.is_action_released("jump")):
		if character.velocity.y < 0:
			character.velocity.y = (character.velocity.y * 0.5)
	if (event.is_action_pressed("crouch")) and !(character.is_wall_sliding):
		character.quickfall()

func wall_jump():
	character.velocity.x = (character.get_wall_jump_direction() * wall_jump_x)
	character.velocity.y = wall_jump_y
	character.start_wall_jump_control_timer()

func walldash():
	character.start_dash_timer()

func on_exit():
	character.is_wall_sliding = false
