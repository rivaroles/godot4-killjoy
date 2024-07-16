extends Area3D

@onready var mesh_instance_3d = $MeshInstance3D
@onready var animation_player = $AnimationPlayer


func _ready():
	animation_player.play("Common")
	
func _on_area_entered(_area):
	if _area.name == "Player":
		queue_free()
		print('Exp collected')
