extends CharacterBody3D


var player = null
var state_machine

@export var speed = 4

const ATTACK_RANGE = 2.0

@export var base_health := 100
var health = 100
@export var base_dmg := 30
var dmg = 30
var round_modifier: int = 10

var max_damage: int = 100

@export var player_path := "../Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@export var waves := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	health = int(base_health * 1.1 ** (waves-1))
	if waves <= 1:
		dmg = base_dmg
	else:
		dmg = int(min(max_damage, base_dmg + 
					(round_modifier * ((waves - 1) / 5))))
	print(health)
	print(dmg)
	if waves <= 3:
		speed = 0.5
	else:
		speed = 4
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Walk":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Run":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * speed
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	if speed == 0.5:
		anim_tree.set("parameters/conditions/walk", !_target_in_range())
	if speed == 4:
		anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	
	move_and_slide()


func _target_in_range():
	if anim_tree.get("parameters/conditions/attack"):
		return global_position.distance_to(player.global_position) < 1.2 * ATTACK_RANGE
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	




func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.take_damage(dmg)


func _on_area_3d_body_part_hit(dmg, critical_multi) -> void:
	#print("hit")
	health -= dmg * critical_multi
	player.currency += 10 * critical_multi

	if health <= 0:
		player.currency += 100
		if $CollisionShape3D:
			$CollisionShape3D.queue_free()
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(6).timeout
		queue_free()
