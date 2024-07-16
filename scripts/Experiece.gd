extends Area3D

@export var experience = 1

@onready var mesh_exp = $MeshInstance3D
@onready var animation_player = $AnimationPlayer
@onready var collision_area = $CollisionShape3D


var target = null
var speed = 0

func _ready():
	animation_player.play("Common")
	
func _physics_process(_delta):
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * _delta
	
func collect():
	collision_area.call_deferred("set", "disabled", true)
	mesh_exp.visible = false
	return experience
