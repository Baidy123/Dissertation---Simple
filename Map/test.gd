extends StaticBody3D


func _process(delta: float):
	#$MeshInstance3D.visible = !!$InteractableComponent.get_character_hovered_by_cur_camera()
	var character = $InteractableComponent.get_character_hovered_by_cur_camera()
	if character:
		character.get_node("PlayerHUD").get_node("InteractiveText").text = str(character.get_node("WeaponManager").current_weapon.fullfill_money)
		character.get_node("PlayerHUD").get_node("InteractiveText").visible = true
	else:
		if has_node("../../Player"):
			#print("nmsl")
			var local_player = get_node("../../Player")
			#print(local_player)
			local_player.get_node("PlayerHUD").get_node("InteractiveText").visible = false
	
