extends CharacterBase

enum INPUT_STATE{MOVE, ATTACK}
var input_state:int


func _ready():
	super()
	spell_book.add_spell(load("res://Spells/missle/missle.tres").duplicate())
	spell_book.add_spell(load("res://Spells/heal/heal.tres").duplicate())
	
func _unhandled_input(event):
	match input_state:
		INPUT_STATE.MOVE:
			if event.is_action_pressed("left_mouse_click") == false:
				return
			set_id_path(tile_map.local_to_map(get_global_mouse_position()))
			
		INPUT_STATE.ATTACK:
			if event.is_action_pressed("left_mouse_click"):
				if next_attack.cooldown==0:
					cast_spell(get_global_mouse_position(), "ally", next_attack)
					next_attack=null
				input_state = INPUT_STATE.MOVE
				#var b = next_attack.instantiate()
				#b.target = get_global_mouse_position()
				#b.protected_group = "ally"
				#b.transform = global_transform
				#add_sibling(b)
				
			
func _physics_process(delta):
	move_path()
	


func _on_area_2d_body_entered(body):
	if(TurnQueue.turn_mode==false):
		call_deferred("turn_modeON")
		#body.call_deferred("turn_modeON");

#UI STUFF
func _on_end_turn_button_pressed():#TODO
	if TurnQueue.turn_mode:
		TurnQueue.play_turn()

func _on_attack_button_button_down():#TODO
	if input_state == INPUT_STATE.MOVE:
		input_state = INPUT_STATE.ATTACK
	else:
		input_state = INPUT_STATE.MOVE
	
func _on_spells_ui_child_entered_tree(node):
	node.connect("pressed", Callable(self, "_spell_button_pressed").bind(node))

func _spell_button_pressed(spell_button:SpellButton):
	if input_state == INPUT_STATE.MOVE:
		input_state = INPUT_STATE.ATTACK
		next_attack = spell_book.get_indexed_spell(spell_button.spell_index)
	else:
		input_state = INPUT_STATE.MOVE
