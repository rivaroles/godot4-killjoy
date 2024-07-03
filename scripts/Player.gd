extends CharacterBody3D

# Player node vars
@onready var head = $Head
@onready var standing_position = $Standing
@onready var crouching_position = $Crouching
@onready var roof_check = $RayCast3D

# Speed vars (player speed)
var current_speed = 5.0
const WALKING = 5.0
const SPRINT = 10.0
const CROUCHING = 3.0

# Jumping force
const JUMP_VELOCITY = 4.5

const MOUSE_SENSE = 0.25

var lerp_speed = 10.0

var direction = Vector3.ZERO

var crouching_depth = -0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSE))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSE))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _physics_process(_delta):
	
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCHING
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, _delta * lerp_speed)
		standing_position.disabled = true
		crouching_position.disabled = false
		
	elif !roof_check.is_colliding():
		standing_position.disabled = false
		crouching_position.disabled = true
		head.position.y = lerp(head.position.y, 1.8, _delta * lerp_speed)
		# Check if sprinting
		if Input.is_action_pressed("sprint"):
			current_speed = SPRINT
		else:
			current_speed = WALKING
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * _delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), _delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
