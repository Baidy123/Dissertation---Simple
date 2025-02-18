extends AnimatableBody3D
@export var cost = 500
#var door_opend := 0
var map = null
@export var map_path := "../../.."



#func _ready() -> void:
	#map = get_node(map_path)
	#door_opend = map.door_opened
	
func _on_interactable_component_interacted() -> void: 	
	if has_node("../../Player"):
		var local_player = get_node("../../Player")
		if local_player.currency < cost:
			return
		local_player.currency -= cost
		get_tree().call_group("Doors","new_door_opened")
		$InteractableComponent.queue_free()
		$AnimationPlayer.play("Open")
	
		#door_opend += 1
		#map.door_opened = door_opend
		$Label3D.visible = false
		await  get_tree().create_timer(3).timeout
		queue_free()
	else:
		print("no player found")
	
func _on_other_interactable_component_interacted() -> void:
	#await  get_tree().create_timer(3).timeout
	queue_free()
	
func _process(delta: float):
	if $InteractableComponent:
		$Label3D.text = "Cost " + str(cost) + " to open this area"
		$Label3D.visible = !!$InteractableComponent.get_character_hovered_by_cur_camera()
	
func new_door_opened():
	#door_opend += 1
	cost += 500

	
