extends Node3D

const ENEMY = preload("res://scenes/Enemy.tscn")
@onready var spawns = $SpawnHolder
@onready var nav_region = $Stage/NavigationRegion3D

var instance

func _ready():
	randomize()

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	return parent_node.get_child(random_id)
	
func _on_spawner_timer_timeout():
	var spawn_point = _get_random_child(spawns).global_position
	instance = ENEMY.instantiate()
	instance.position = spawn_point
	nav_region.add_child(instance)
