extends Node3D

const BULLET_SPEED = 40.0

@onready var mesh_instance = $MeshInstance3D
@onready var ray_cast = $RayCast3D

func _process(_delta):
	
	position += transform.basis * Vector3(0, 0, -BULLET_SPEED) * _delta
