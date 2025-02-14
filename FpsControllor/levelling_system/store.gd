extends Control



#var skill_available_points : int
#var attribute_available_points : int 
var currency :int 
var selected_weapon_id := ""
#
#var constitution_add = 0
#var strength_add = 0
#var perception_add = 0
#
#var endurance_add = 0
#var resilience_add = 0
#var melee_add = 0
#var intimidation_add = 0
#var handguns_add = 0
#var longguns_add = 0
@onready var character = get_node("../../Player")
@onready var levelling_sys = get_node("../../Player/LevellingSystem")

func _ready() -> void:
	
	if character and character.has_node("PlayerHUD"):
		character.get_node("PlayerHUD").set_visible(false)
		character.get_node("PlayerHUD").set_process_unhandled_input(false) 
		
	for button in get_tree().get_nodes_in_group("WeaponButtons"):
		button.set_disabled(false)
		# 让每个按钮的 pressed 信号连接到同一个函数，并传入按钮名字(或自定义 ID)
		button.pressed.connect(_on_weapon_button_pressed.bind(button.get_name()))
	%PurchaseButton.pressed.connect(_on_purchase_button_pressed)
	$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/NameLabel.text = ""
	$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/CostLabel.text = ""
	$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/DescLabel.text = ""
	$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/WarningLabel.text = ""
	#$HBoxContainer/VBoxContainer/Attributes.set_visible(true)
	#$HBoxContainer/VBoxContainer/Skills.set_visible(false)
	$HBoxContainer/VBoxContainer/Weapons.set_visible(true)
	$HBoxContainer/VBoxContainer/Perks.set_visible(false)
	currency = character.currency
	#load_stats()
	load_perks()
	_update_weapon_buttons()
	#attribute_available_points = character.attribute_available_points
	#skill_available_points = character.skill_available_points
	
	#for button in get_tree().get_nodes_in_group("AttributePlusButtons"):
		#button.set_disabled(true)
		#button.set_visible(false)
	#for button in get_tree().get_nodes_in_group("AttributeMinusButtons"):
		#button.set_disabled(true)
		#button.set_visible(false)
	#%AttributeAvailablePoints.set_text("Points: " + str(attribute_available_points))
	#if attribute_available_points == 0:
		#$HBoxContainer/VBoxContainer/Attributes/AttributeName/AttributePoints.set_visible(false)
		#$HBoxContainer/VBoxContainer/Attributes/AttributeName/AttributePoints/AttributeConfirm.set_visible(false)
	#else:
		#for button in get_tree().get_nodes_in_group("AttributePlusButtons"):
			#button.set_disabled(false)
			#button.set_visible(true)
	
	#elif $HBoxContainer/VBoxContainer/Skills.visible == true:
		
	#for button in get_tree().get_nodes_in_group("SkillPlusButtons"):
		#button.set_disabled(true)
		#button.set_visible(false)
		##print(button.get_parent().get_parent().name.to_lower())
		#button.pressed.connect(increase_skill.bind(button.get_parent().get_parent().name)) 
	#for button in get_tree().get_nodes_in_group("SkillMinusButtons"):
		#button.set_disabled(true)
		#button.set_visible(false)
		#button.pressed.connect(decrease_skill.bind(button.get_parent().get_parent().name)) 
	#%SkillAvailablePoints.set_text("Points: " + str(skill_available_points))
	%PerkPoints.set_text("$ " + str(character.currency))
	#if skill_available_points == 0:
		#pass
		#$HBoxContainer/VBoxContainer/Attribute/AttributeName/AttributePoints.set_visible(false)
	#else:
		#for button in get_tree().get_nodes_in_group("SkillPlusButtons"):
			#button.set_disabled(false)
			#button.set_visible(true)
func _on_weapon_button_pressed(weapon_button_name: String) -> void:
	# weapon_button_name 可能是 "pistol_button", "rifle_button", etc.
	# 你可以把按钮的名称和 weapons_info 里的 key 对应，也可以在按钮脚本或 metadata 中存真正的 weapon_id。
	# 下面演示最简单的情况：假设你的按钮名字就直接等于武器id (pistol, rifle)
	# 如果不一样，可以使用 Dictionary 或 metadata 去映射。
	selected_weapon_id = weapon_button_name.to_lower()

	# 从字典里获取相应信息
	if character.weapons.has(selected_weapon_id):
		var w_info = character.weapons[selected_weapon_id]
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/NameLabel.text = w_info["name"]
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/CostLabel.text = "Cost: " + str(w_info["price"])
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/DescLabel.text = w_info["description"]
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/WarningLabel.text = ""
	else:
		# 如果没找到
		selected_weapon_id = ""
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/NameLabel.text = ""
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/CostLabel.text = ""
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/DescLabel.text = "Weapon not found..."
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/WarningLabel.text = ""
		
func _on_purchase_button_pressed() -> void:
	if selected_weapon_id == "":
		%Warning.text = "No weapon selected."
		return

	if not character.weapons.has(selected_weapon_id):
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/WarningLabel.text = "Invalid weapon."
		return

	var w_info = character.weapons[selected_weapon_id]
	var cost = w_info["price"]

	# 1. 检查玩家金钱
	if currency < cost:
		%Warning.text = "Not enough money!"
		return

	# 2. 扣除金钱
	currency -= cost
	character.weapons[selected_weapon_id]["owned"] = true
	_update_weapon_buttons()
	selected_weapon_id = ""
	
	
	# 4. 加载对应的 .tres 并添加到玩家的武器管理器
	var weapon_file_path = w_info["file_path"]
	var weapon_resource = load(weapon_file_path)
	if weapon_resource == null:
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/WarningLabel.text = "Weapon resource not found: " + weapon_file_path
		return

	# 假设你的 Player 节点或 WeaponManager 有一个 add_weapon(res) 方法
	var weapon_manager = get_node("../../Player/WeaponManager")  # 修改成你实际的路径
	if weapon_manager and weapon_manager.has_method("add_weapon"):
		weapon_manager.add_weapon(weapon_resource)
	else:
		$HBoxContainer/VBoxContainer/Weapons/WeaponInfo/Panel/MarginContainer/Info/WeaponInfo/WarningLabel.text = "Can't add weapon. WeaponManager not found or missing add_weapon method."

	# 5. 提示购买成功
	%Warning.text = "Purchase success!"

	
func _update_weapon_buttons() -> void:
	%Currency.text = "$ " + str(currency)
	for weapon_id in character.weapons:
		var w_info = character.weapons[weapon_id]
		var button_path = "HBoxContainer/VBoxContainer/Weapons/WeaponName/%s" % weapon_id
		var wbutton = get_node(button_path)
		print(wbutton)
		if wbutton:
			print(w_info["owned"])
			# 如果 owned = true，就隐藏按钮；否则显示
			if w_info["owned"] == true:
				wbutton.visible = false
			else:
				wbutton.visible = true

func load_perks():
	if not character:
		return
	
	for button in get_tree().get_nodes_in_group("PerksButtons"):
		var perk_id = button.get_name().to_lower()
		var child_node = null
		button.tooltip_text =  str(levelling_sys.perk_requirement[perk_id]["name"].to_upper()
								+ ": " + levelling_sys.perk_requirement[perk_id]["description"])
		button.pressed.connect(spend_perk_points.bind(button.name.to_lower())) 
		if button.has_node("TextureRect"):
			child_node = button.get_node("TextureRect")

		
		if perk_id in character.perks and character.perks[perk_id] == true:
			
			if child_node:
				child_node.visible = true
			
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:

			if check_perk_requirements(perk_id):
			
				
				if child_node:
					child_node.visible = false
				button.disabled = false
			else:
				
				if child_node:
					child_node.visible = false
				button.disabled = true


func check_perk_requirements(perk_id: String) -> bool:
	if not levelling_sys.perk_requirement.has(perk_id):
		return false  

	var req_dict =  levelling_sys.perk_requirement[perk_id]

	#if req_dict.has("attribute"):
		#for attr_name in req_dict["attribute"]:
			#var required_val = req_dict["attribute"][attr_name]
			#var current_val = character.attributes[attr_name] if character.attributes.has(attr_name) else 0
			#if current_val < required_val:
				#return false
	#if req_dict.has("skill"):
		#for skill_name in req_dict["skill"]:
			#var required_val = req_dict["skill"][skill_name]
			#var current_val = character.skills[skill_name] if character.skills.has(skill_name) else 0
			#if current_val < required_val:
				#return false
				
	if req_dict.has("currency"):
		var required_val =  req_dict["currency"]
		if character.currency < required_val:
			return false

	return true

#func increase_attribute(stat: String):
	#set(stat.to_lower() + "_add", get(stat.to_lower() + "_add") +1)
	#%AttributeName.get_node(stat + "/Panel/Stats/Change").set_text("+" + str(
												#get(stat.to_lower() + "_add")) + " ")
	#%AttributeName.get_node(stat + "/Panel/Min").set_disabled(false)
	#%AttributeName.get_node(stat + "/Panel/Min").set_visible(true)
	#attribute_available_points -= 1
	#%AttributeAvailablePoints.set_text("Points: " + str(attribute_available_points))
	#if attribute_available_points == 0:
		#for button in get_tree().get_nodes_in_group("AttributePlusButtons"):
			#button.set_disabled(true)
			#button.set_visible(false)
	#print(stat + "Plus")
	#
#func decrease_attribute(stat: String):
	#set(stat.to_lower() + "_add", get(stat.to_lower() + "_add") -1)
	#if get(stat.to_lower() + "_add") == 0:
		#%AttributeName.get_node(stat + "/Panel/Min").set_disabled(true)
		#%AttributeName.get_node(stat + "/Panel/Min").set_visible(false)
		#%AttributeName.get_node(stat + "/Panel/Stats/Change").set_text("")
	#else :
		#%AttributeName.get_node(stat + "/Panel/Stats/Change").set_text("+" + str(
												#get(stat.to_lower() + "_add")) + " ")
	#attribute_available_points += 1
	#%AttributeAvailablePoints.set_text("Points: " + str(attribute_available_points))
	#for button in get_tree().get_nodes_in_group("AttributePlusButtons"):
		#button.set_disabled(false)
		#button.set_visible(true)
	#print((stat + "Minus"))
	
#func increase_skill(stat: String):
	#set(stat.to_lower() + "_add", get(stat.to_lower() + "_add") +1)
	#%SkillName.get_node(stat + "/Panel/Stats/Change").set_text("+" + str(
												#get(stat.to_lower() + "_add")) + " ")
	#%SkillName.get_node(stat + "/Panel/Min").set_disabled(false)
	#%SkillName.get_node(stat + "/Panel/Min").set_visible(true)
	#skill_available_points -= 1
	#%SkillAvailablePoints.set_text("Points: " + str(skill_available_points))
	#if skill_available_points == 0:
		#for button in get_tree().get_nodes_in_group("SkillPlusButtons"):
			#button.set_disabled(true)
			#button.set_visible(false)
	#print(stat + "Plus")
	#
#func decrease_skill(stat: String):
	#set(stat.to_lower() + "_add", get(stat.to_lower() + "_add") -1)
	#if get(stat.to_lower() + "_add") == 0:
		#%SkillName.get_node(stat + "/Panel/Min").set_disabled(true)
		#%SkillName.get_node(stat + "/Panel/Min").set_visible(false)
		#%SkillName.get_node(stat + "/Panel/Stats/Change").set_text("")
	#else :
		#%SkillName.get_node(stat + "/Panel/Stats/Change").set_text("+" + str(
												#get(stat.to_lower() + "_add")) + " ")
	#skill_available_points += 1
	#%SkillAvailablePoints.set_text("Points: " + str(skill_available_points))
	#for button in get_tree().get_nodes_in_group("SkillPlusButtons"):
		#button.set_disabled(false)
		#button.set_visible(true)
	#print((stat + "Minus"))
	
func spend_perk_points(perk_id: String):
	if not character:
		return
	if not levelling_sys.perk_requirement.has(perk_id):
		return
	var req_dict = levelling_sys.perk_requirement[perk_id]
	var cost = 1
	if req_dict.has("currency"):
		cost = req_dict["currency"]
	character.perks[perk_id] = true
	character.currency -= cost
	%PerkPoints.set_text("$ " + str(character.currency))
	for button in get_tree().get_nodes_in_group("PerksButtons"):
		if button.get_name().to_lower() == perk_id:
			if button.has_node("TextureRect"):
				var child_node = button.get_node("TextureRect")
				child_node.visible = character.perks[perk_id]  
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			load_perks()
			break

	#
#func _on_attribute_confirm_pressed() -> void:
	#if strength_add + constitution_add + perception_add == 0:
		#print("Nothing changed")
	#else :
		#character.attribute_available_points = attribute_available_points
		#character.attributes["constitution"] += constitution_add
		#character.attributes["strength"] += strength_add
		#character.attributes["perception"] += perception_add
		#character.skills["endurance"] += constitution_add * 5
		#character.skills["resilience"] += constitution_add * 5
		#character.skills["melee"] += strength_add * 5
		#character.skills["intimidation"] += strength_add * 5
		#character.skills["handguns"] += perception_add * 5
		#character.skills["longguns"] += perception_add * 5
		#
		#strength_add = 0
		#constitution_add = 0
		#perception_add = 0
		#load_stats()
		#for button in get_tree().get_nodes_in_group("AttributeMinusButtons"):
			#button.set_visible(false)
		#for label in get_tree().get_nodes_in_group("AttributeChangeLabels"):
			#label.set_text(" ")
		#if attribute_available_points == 0:
			#$HBoxContainer/VBoxContainer/Attributes/AttributeName/AttributePoints/AttributeConfirm.set_visible(false)

#func _on_skill_confirm_pressed() -> void:
	#if endurance_add + resilience_add + melee_add + intimidation_add + handguns_add + longguns_add == 0:
		#print("Nothing changed")
	#else :
		#character.skill_available_points = skill_available_points
		#character.skills["endurance"] += endurance_add
		#character.skills["resilience"] += resilience_add
		#character.skills["melee"] += melee_add
		#character.skills["intimidation"] +=intimidation_add
		#character.skills["handguns"] += handguns_add
		#character.skills["longguns"] += longguns_add
		#endurance_add = 0
		#resilience_add = 0
		#melee_add = 0
		#intimidation_add = 0
		#handguns_add = 0
		#longguns_add = 0
		#load_stats()
		#for button in get_tree().get_nodes_in_group("SkillMinusButtons"):
			#button.set_visible(false)
		#for label in get_tree().get_nodes_in_group("SkillChangeLabels"):
			#label.set_text(" ")




func _process(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		

	
func _exit_tree(): 
	#character.sprint_multi *= 1+character.skills["endurance"]*0.01
	#print(character.sprint_multi)
	#levelling_sys.update_influence_from_skills()
	if character and character.has_node("PlayerHUD"):
		character.get_node("PlayerHUD").visible = true  
		character.get_node("PlayerHUD").set_process_unhandled_input(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	



func _on_attribute_pressed() -> void:
	$HBoxContainer/VBoxContainer/Weapons.show()
	$HBoxContainer/VBoxContainer/Perks.hide()
	_update_weapon_buttons()
	
	


func _on_skills_pressed() -> void:
	$HBoxContainer/VBoxContainer/Attributes.hide()
	$HBoxContainer/VBoxContainer/Skills.show()
	$HBoxContainer/VBoxContainer/Perks.hide()



func _on_perks_pressed() -> void:
	$HBoxContainer/VBoxContainer/Weapons.hide()
	$HBoxContainer/VBoxContainer/Perks.show()
	load_perks()
