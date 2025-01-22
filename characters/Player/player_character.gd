extends CharacterBase

enum INPUT_STATE{MOVE, ATTACK}
var input_state:int


func _ready():
	super()
	spell_book.add_spell(load("res://Spells/missle/missle.tres").duplicate())
	spell_book.add_spell(load("res://Spells/heal/heal.tres").duplicate())
	spell_book.add_spell(load("res://Spells/slash/slash.tres").duplicate())
	spell_book.add_spell(load("res://Spells/Shield/shield.tres").duplicate())
	spell_book.get_indexed_spell(0).upgrade()
	spell_book.get_indexed_spell(0).upgrade()
	spell_book.get_indexed_spell(0).upgrade()
	
func _unhandled_input(event):
	if TurnQueue.turn_mode == false or TurnQueue.active_char == self:
		match input_state:
			INPUT_STATE.MOVE:
				if event.is_action_pressed("left_mouse_click") == false:
					return
				else:
					set_id_path(tile_map.local_to_map(get_global_mouse_position()))
				
			INPUT_STATE.ATTACK:
				if event.is_action_pressed("left_mouse_click"):
					if next_attack.cooldown==0:
						if check_spell_range(next_attack,get_global_mouse_position()):
							cast_spell(get_global_mouse_position(), "ally", next_attack)
							next_attack=null
						else:
							next_attack=null
					input_state = INPUT_STATE.MOVE
					#var b = next_attack.instantiate()
					#b.target = get_global_mouse_position()
					#b.protected_group = "ally"
					#b.transform = global_transform
					#add_sibling(b)
				
			
func _physics_process(delta):
	super(delta)
	move_path()
	


func _on_area_2d_body_entered(_body):
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
	current_id_path = [tile_map.local_to_map(global_position)]
	
	if input_state == INPUT_STATE.ATTACK and spell_book.get_indexed_spell(spell_button.spell_index) == next_attack:
		input_state = INPUT_STATE.MOVE
		next_attack = null
	else:
		input_state = INPUT_STATE.ATTACK
		next_attack = spell_book.get_indexed_spell(spell_button.spell_index)
