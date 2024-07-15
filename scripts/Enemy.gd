extends CharacterBody3D

var player = null
var health = 6.0

const  SPEED = 4.0

const EXPERIENCE := preload("res://scenes/Experiece.tscn")

@export var player_path := "/root/World/Stage/NavigationRegion3D/Player"

@onready var main = get_node("/root/World")
@onready var nav_agent = $NavigationAgent3D
@onready var animation_player = $AnimationPlayer
@onready var mesh_instance_3d = $MeshInstance3D

func _ready():
	player = get_node(player_path)

func _process(_delta):
	
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(player.global_transform.origin)
	var next_location = nav_agent.get_next_path_position()
	velocity = (next_location - global_transform.origin).normalized() * SPEED
	
	move_and_slide()
	
func exp_drop():
	var exp_inst = EXPERIENCE.instantiate()
	exp_inst.position = position
	main.call_deferred("add_child", exp_inst)
	exp_inst.add_to_group("experience")
	
func take_damage():
	health -= 1
	animation_player.play("Hurt")
	
	if health == 0:
		queue_free()
	
