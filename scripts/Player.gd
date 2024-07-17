extends CharacterBody3D

# Player nodes
@onready var neck = $Neck
@onready var head = $Neck/Head
@onready var eyes = $Neck/Head/Eyes
@onready var standing_position = $Standing
@onready var crouching_position = $Crouching
@onready var roof_check = $RoofCheck
@onready var camera_3d = $Neck/Head/Eyes/Camera3D
@onready var jump_sound = $Sounds/JumpSound
@onready var shoot_sound = $Sounds/ShootSound
@onready var jetpack_sound = $Sounds/JetpackSound
@onready var shoot_timer = $ShootTimer

# Health nodes
var hp = 120.0

# Level nodes
var experience = 0
var experience_level = 1
var collected_experience = 0

# Gun nodes
@onready var gun_barrel = $Neck/Head/Eyes/Camera3D/Blaster/RayCast3D
@onready var gun = $Neck/Head/Eyes/Camera3D/Blaster/AnimationPlayer


var bullet = load("res://scenes/Bullet.tscn")
var instance

# Speed vars (player speed)
var current_speed = 5.0

const WALKING = 5.0
const SPRINT = 10.0
const CROUCHING = 3.0

# States

var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false
var gliding = false

# Sliding vars

var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

# Jetpack vars

const JETPACK_FORCE = 10.0
const MAX_JETPACK_FUEL = 10.0

var jetpack_fuel = 10.0
var fuel_consumption = 3.0
var fuel_recharge = 0.5

# Head bob vars
const HEAD_BOBBING_SPRINTING_SPEED = 22.0
const HEAD_BOBBING_WALKING_SPEED = 14.0
const HEAD_BOBBING_CROUCHING_SPEED = 10.0

const HEAD_BOBBING_SPRINTING_INTENSITY = 0.2
const HEAD_BOBBING_WALKING_INTENSITY = 0.1
const HEAD_BOBBING_CROUCHING_INTENSITY = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# Movement vars
const JUMP_VELOCITY = 4.5
const MAX_HEIGHT = 10.0

var crouching_depth = -0.5
var free_look_tilt = 8

# Input vars
const MOUSE_SENSE = 0.25
var direction = Vector3.ZERO

var lerp_speed = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	
	# Mouse looking
	
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSE))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-90), deg_to_rad(90))
		else:
			rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSE))
			head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSE))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(_delta):
	
	# Quitting the game (change to menu later)
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true

func _physics_process(_delta):
	
	# Getting movement input
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	# Handling movement states
	
	# Crouching state
	if Input.is_action_pressed("crouch") || sliding:
		current_speed = CROUCHING
		head.position.y = lerp(head.position.y, crouching_depth, _delta * lerp_speed)
		standing_position.disabled = true
		crouching_position.disabled = false
		
		# Slide begin
		
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
		
		walking = false
		sprinting = false
		crouching = true
		
	elif !roof_check.is_colliding():
		
		# Standing state
		standing_position.disabled = false
		crouching_position.disabled = true
		head.position.y = lerp(head.position.y, 0.0, _delta * lerp_speed)
		
		# Sprinting state
		if Input.is_action_pressed("sprint"):
			current_speed = SPRINT
			
			walking = false
			sprinting = true
			crouching = false
			
		else:
			current_speed = WALKING
			
			walking = true
			sprinting = false
			crouching = false
			
	# Handling free look
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			camera_3d.rotation.z = lerp(camera_3d.rotation.z, -deg_to_rad(7.0), _delta * lerp_speed)
		else:
			camera_3d.rotation.z = -deg_to_rad(neck.rotation.y * free_look_tilt)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, _delta * lerp_speed)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, _delta * lerp_speed)
		
	# Handle sliding
	if sliding:
		slide_timer -= _delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
			
	# Handle shooting
	if Input.is_action_pressed("shoot"):
		if !gun.is_playing():
			shoot_sound.play()
			gun.play("Shoot")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
	
	# Head bobbing
	if sprinting:
		head_bobbing_current_intensity = HEAD_BOBBING_SPRINTING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_SPRINTING_SPEED * _delta
	elif walking:
		head_bobbing_current_intensity = HEAD_BOBBING_WALKING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_WALKING_SPEED * _delta
	elif crouching:
		head_bobbing_current_intensity = HEAD_BOBBING_CROUCHING_INTENSITY
		head_bobbing_index += HEAD_BOBBING_CROUCHING_SPEED * _delta
		
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index / 2) + 0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y * (head_bobbing_current_intensity / 2.0), _delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x * head_bobbing_current_intensity, _delta * lerp_speed)
		
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0, _delta * lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0, _delta * lerp_speed)
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * _delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") && is_on_floor() && crouching != true:
		velocity.y = JUMP_VELOCITY
		sliding = false
		jump_sound.play()
	
	elif Input.is_action_pressed("jump") && !is_on_floor() && jetpack_fuel > 0:
		velocity.y += JETPACK_FORCE * _delta
		jetpack_fuel -= fuel_consumption * _delta
	
	elif is_on_floor():
		jetpack_fuel = min(jetpack_fuel + fuel_recharge * _delta, MAX_JETPACK_FUEL)

	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), _delta * lerp_speed)
	
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		if sliding:
			velocity.x = direction.x * (slide_timer + 0.1) * slide_speed
			velocity.z = direction.z * (slide_timer + 0.1) * slide_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
	
	if global_transform.origin.y > MAX_HEIGHT:
		global_transform.origin.y = MAX_HEIGHT
		velocity.y = 0


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self


func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)
		
func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		print("Level:", experience_level)
		experience = 0
		exp_required = calculate_experiencecap()
		calculate_experience(0)
	else:
		experience += collected_experience
		collected_experience = 0
	
func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap + 95 * (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
		
	return exp_cap

func _on_hurt_box_hurt(damage):
	hp -= damage
	print(hp)
