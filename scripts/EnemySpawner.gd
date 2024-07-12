extends Node3D

const ENEMY = preload("res://scenes/Enemy.tscn")
@onready var random = RandomNumberGenerator.new()

var dead_enemies = 0

func _ready():
	add_to_group("World")
	
func enemy_death():
	print("enemy dead" + dead_enemies)
	dead_enemies += 1
	
func spawn_enemies():
	print("enemy spawned")
	var spawned = ENEMY.instantiate()
	var spawn_length = $"Spawn Holder".get_child_count() - 1
	var rand_num = random.randi_range(0, spawn_length)
	var spawn_position = $"Spawn Holder".get_child(rand_num).position
	
	spawned.position = spawn_position
	add_child(spawned)
	

func update_level():
	spawn_enemies()
