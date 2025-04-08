extends CharacterBody2D
#base player script is for handling functions and variables that persist between or regardles of states

@export var speed : float = 200.0
@export var max_fall_speed : float = 700
@export var coyote_time : float = 0.2
@export var jump_buffer_time : float = 0.2
@export var wall_jump_control_time : float = 0.1
@export var jump_control_time : float = 0.2
@export var dash_time : float = 0.2
@export var dash_speed : float = 600.0
@export var dash_cooldown : float = 0.5
@export var quickfall_speed : float = 700
@export var quickfall_windup : float = 0.2

@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : CharacterStateMachine = $CharacterStateMachine
@onready var wall_raycast : RayCast2D = $wall_raycast

var is_quickfalling : bool = false
var quickfall_ready : bool = false
var is_wall_sliding : bool = false
var is_dashing : bool = false
var can_dash : bool = true
var has_coyote_time : bool = false
var has_jump_buffer : bool = false
var jump_held : bool = false
var move_lock : bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2 = Vector2.ZERO

func _ready():
	animation_tree.active = true

func _physics_process(delta):
	direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_pressed("jump"):
		jump_held = true
	else:
		jump_held = false
	
	if quickfall_ready:
		velocity.y = 0
	if is_quickfalling:
		velocity.y = quickfall_speed
	
	
	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	pass
	#animation_tree.set("parameters/Move/blend_position", direction.x)

func update_facing_direction():
	if direction.x > 0:
		sprite.flip_h = false
		wall_raycast.scale.x = 1
	if direction.x < 0:
		sprite.flip_h = true
		wall_raycast.scale.x = -1

func quickfall():
	move_lock = true
	velocity.x = 0
	velocity.y = 0
	get_tree().create_timer(quickfall_windup).timeout.connect(quickfall_dive)
	quickfall_ready = true

func quickfall_dive():
	quickfall_ready = false
	is_quickfalling = true

func start_dash_timer():
	if is_quickfalling:
		is_quickfalling = false
	can_dash = false
	get_tree().create_timer(dash_time).timeout.connect(dash_timeout)
	move_lock = true
	velocity.x = 0
	is_dashing = true
	if is_wall_sliding:
		velocity.x = dash_speed * get_wall_jump_direction() * -1
	else:
		velocity.x = dash_speed * get_wall_jump_direction()

func dash_timeout():
	is_dashing = false
	velocity.x = 0
	move_lock = false
	get_tree().create_timer(dash_cooldown).timeout.connect(dash_cooldown_timeout)
	if (state_machine.current_state == $CharacterStateMachine/Ground) and (has_jump_buffer) and (jump_held):
		$CharacterStateMachine/Ground.jump()
	if (state_machine.current_state == $CharacterStateMachine/Air) and (has_jump_buffer) and (jump_held) and (has_coyote_time):
		$CharacterStateMachine/Ground.jump()
	elif (state_machine.current_state == $CharacterStateMachine/Air) and (has_jump_buffer) and (jump_held) and !($CharacterStateMachine/Air.has_double_jumped):
		$CharacterStateMachine/Air.double_jump()

func dash_cooldown_timeout():
	can_dash = true

func start_wall_jump_control_timer():
	get_tree().create_timer(wall_jump_control_time).timeout.connect(wall_jump_timeout)
	move_lock = true

func wall_jump_timeout():
	move_lock = false

func start_coyote_time():
	get_tree().create_timer(coyote_time).timeout.connect(coyote_timeout)
	has_coyote_time = true

func coyote_timeout():
	has_coyote_time = false

func buffer_jump():
	get_tree().create_timer(jump_buffer_time).timeout.connect(jump_buffer_timeout)
	has_jump_buffer = true

func jump_buffer_timeout():
	has_jump_buffer = false

func get_wall_jump_direction():
	return wall_raycast.scale.x
