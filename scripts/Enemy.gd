extends CharacterBody3D

var player = null
var health = 10.0

const  SPEED = 4.0

@export var player_path := "/root/World/Stage/NavigationRegion3D/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var animation_player = $AnimationPlayer


func _ready():
	player = get_node(player_path)

func _process(_delta):
	
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(player.global_transform.origin)
	var next_location = nav_agent.get_next_path_position()
	velocity = (next_location - global_transform.origin).normalized() * SPEED
	
	move_and_slide()
	
func take_damage():
	health -= 1
	animation_player.play("Hurt")
	
	if health == 0:
		queue_free()
	
