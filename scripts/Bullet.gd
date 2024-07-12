extends Area3D

const BULLET_SPEED = 80.0

@onready var mesh_instance = $MeshInstance3D
@onready var ray_cast = $RayCast3D

func _physics_process(_delta):
	
	position += transform.basis * Vector3(0, 0, -BULLET_SPEED) * _delta

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage()
