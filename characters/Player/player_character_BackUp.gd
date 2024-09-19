extends CharacterBase

enum INPUT_STATE{MOVE, ATTACK}
var input_state:int


func _ready():
	super()
	spell_book.add_spell(load("res://Spells/missle/missle.tres"))
	
func _unhandled_input(event):
	match input_state:
		INPUT_STATE.MOVE:
			if event.is_action_pressed("left_mouse_click") == false:
				return
			var id_path = astar_grid.get_id_path(
				tile_map.local_to_map(global_position),
				tile_map.local_to_map((get_global_mouse_position()))
			).slice(1)
			
			if id_path.is_empty() == false:
				current_id_path = id_path
		INPUT_STATE.ATTACK:
			if event.is_action_pressed("left_mouse_click"):
				cast_spell(get_global_mouse_position(), "ally", next_attack)
				#var b = next_attack.instantiate()
				#b.target = get_global_mouse_position()
				#b.protected_group = "ally"
				#b.transform = global_transform
				#add_sibling(b)
				
			
func _physics_process(delta):
	if Input.is_action_just_released("ui_focus_next"):#TODO
			TurnQueue.join_queue(self)
	
	if current_id_path.is_empty():
		return
		
	var target_position = tile_map.map_to_local(current_id_path.front())
	
	move_one_tile(current_id_path.front())
	#global_position = global_position.move_toward(target_position, 3)

	if global_position == target_position:
		current_id_path.pop_front()
	


func _on_area_2d_body_entered(body):
	if(turn_mode==false):
		call_deferred("turn_modeON")
		body.call_deferred("turn_modeON");

#UI STUFF
func _on_end_turn_button_pressed():#TODO
	print("halo")
	TurnQueue.play_turn()

func _on_attack_button_button_down():#TODO
	if input_state == INPUT_STATE.MOVE:
		input_state = INPUT_STATE.ATTACK
	else:
		input_state = INPUT_STATE.MOVE
	
func _on_spells_ui_child_entered_tree(node):
	node.connect("pressed", Callable(self, "_spell_button_pressed").bind(node))

func _spell_button_pressed(node):
	if input_state == INPUT_STATE.MOVE:
		input_state = INPUT_STATE.ATTACK
		next_attack = node.spell_scene
	else:
		input_state = INPUT_STATE.MOVE
