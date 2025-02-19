extends CanvasLayer

@onready var character = get_node("/root/Map/Player")
@onready var levelling_sys = get_node("/root/Map/Player")
@onready var world = $".."
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#var has_init_sheet_opened = false
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact"):
		if has_node("Store"):
			get_node("Store").queue_free()
	#if event.is_action_pressed("charactersheet"):
		#if not has_node("Store"):
			#var store = load("res://FpsControllor/levelling_system/Store.tscn").instantiate()
			#store.door_opened = world.door_unlocked
			#add_child(store)
		#elif has_node("Store"):
			#get_node("Store").queue_free()
func open_store():
	if not has_node("Store"):
		var store = load("res://FpsControllor/levelling_system/Store.tscn").instantiate()
		store.door_opened = world.door_unlocked
		add_child(store)
	#if event.is_action_pressed("initsheet") and !has_init_sheet_opened:
		#has_init_sheet_opened = true
		#if not has_node("InitialSheet"):
			#var init_sheet = load("res://FpsControllor/levelling_system/initial_sheet.tscn").instantiate()
			#add_child(init_sheet)
		#elif has_node("InitialSheet"):
			#get_node("InitialSheet").queue_free()
			


func _on_interactable_component_interacted() -> void:
	#Store
	#if not has_node("Store"):
		#var store = load("res://FpsControllor/levelling_system/Store.tscn").instantiate()
		#add_child(store)
	#Ammo_box
	#if character:
		#character.fullfill_ammo()
	#Upgrade_weapon
	if character:
		character.upgrade_weapon()
	
