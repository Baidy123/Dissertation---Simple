extends CharacterBody3D


var player = null
var state_machine

const SPEED = 4

const ATTACK_RANGE = 2.0

@export var base_health := 100
var health = 100
@export var base_dmg := 30
var dmg = 30
var round_modifier: int = 10
var is_dead := false
var max_damage: int = 100
var attack_range = ATTACK_RANGE
@export var player_path := "../Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@export var waves : int

#var _snapped_to_stairs_last_frame := false
const MAX_STEP_HEIGHT = 0.5
signal zombie_died()
# Called when the node enters the scene tree for the first time.
func _ready():
	health = int(base_health * 1.1 ** (waves-1))
	$Hp.text = str(health)
	#print(health)
	if waves <= 1:
		dmg = base_dmg
	else:
		dmg = int(min(max_damage, base_dmg + 
					(round_modifier * ((waves - 1) / 5))))
	#print(health)
	#print(dmg)

	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")




func _snap_up_to_stairs_check(delta) -> bool :
	#if not is_on_floor() and not _snapped_to_stairs_last_frame : 
		#return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0,MAX_STEP_HEIGHT * 2, 0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if(_run_body_test_motion(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT * 2, 0), down_check_result) 
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_travel() - self.global_position).y > MAX_STEP_HEIGHT: 
			return false
		%StairsAheadRayCast3D.global_position = down_check_result.get_collision_point() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1
		%StairsAheadRayCast3D.force_raycast_update()
		if %StairsAheadRayCast3D.is_colliding():
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			#_snapped_to_stairs_last_frame = true
			return true
	return false
	
func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: 
		result = PhysicsTestMotionResult3D.new()
		
	var param = PhysicsTestMotionParameters3D.new()
	param.from = from
	param.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), param, result)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	if self.global_position.y < -0.6:
		emit_signal("zombie_died")
		queue_free()
		
	if !nav_agent.is_target_reachable() and player.is_on_floor():
		attack_range = ATTACK_RANGE * 3
	else:
		attack_range = ATTACK_RANGE
		
	match state_machine.get_current_node():
		"Run":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			#print(nav_agent.is_target_reachable())
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	#_snapped_to_stairs_last_frame = false
	_snap_up_to_stairs_check(delta)
	move_and_slide()



func _target_in_range():
	if anim_tree.get("parameters/conditions/attack"):
		return global_position.distance_to(player.global_position) < 1.2 * attack_range
	return global_position.distance_to(player.global_position) < attack_range
	




func _hit_finished():
	if global_position.distance_to(player.global_position) < attack_range + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.take_damage(dmg)


func _on_area_3d_body_part_hit(dmg, critical_multi) -> void:
	if is_dead:
		return
	health -= dmg * critical_multi
	player.currency += 10 * critical_multi
	$Hp.text = str(health)
	if health <= 0:
		if not is_dead:
			is_dead = true
		player.currency += 100
		#for hitbox in get_tree().get_nodes_in_group("enemy"):
			#hitbox.queue_free()
		if $CollisionShape3D:
			$CollisionShape3D.queue_free()
		anim_tree.set("parameters/conditions/die", true)
		$Hp.visible = false
		emit_signal("zombie_died")
		await get_tree().create_timer(6).timeout
		queue_free()
