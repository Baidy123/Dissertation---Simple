extends Node3D
#var door_opened : int = 0 
	#set(v):
		#if v != door_opened:
			#door_opened = v
			#calculate_costs_for_opening_doors()
#var open_door_cost : int = 500
#@onready var hit_rect = $UI/HitRect
#@onready var spawns = $Map/Spawns
#@onready var navigation_region = $Map/NavigationRegion3D
#
#var zombie = load("res://Scenes/Zombie.tscn")
#var instance

#func calculate_costs_for_opening_doors():
	#open_door_cost += 500 * door_opened
# Called when the node enters the scene tree for the first time.
#func _ready():
	#randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
#
#
#func _on_player_player_hit():
	#hit_rect.visible = true
	#await get_tree().create_timer(0.2).timeout
	#hit_rect.visible = false
#
#
#func _get_random_child(parent_node):
	#var random_id = randi() % parent_node.get_child_count()
	#return parent_node.get_child(random_id)
#
#func _on_zombie_spawn_timer_timeout():
	#var spawn_point = _get_random_child(spawns).global_position
	#instance = zombie.instantiate()
	#instance.position = spawn_point
	#navigation_region.add_child(instance)
