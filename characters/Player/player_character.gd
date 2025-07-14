class_name PlayerCharacter extends CharacterBase



enum INPUT_STATE{MOVE, ATTACK, BLOCK}
var input_state:int


func _ready():
	super()
	spell_book.add_spell(load("res://Spells/missle/missle.tres").duplicate())
	spell_book.add_spell(load("res://Spells/heal/heal.tres").duplicate())
	spell_book.add_spell(load("res://Spells/slash/slash.tres").duplicate())
	spell_book.add_spell(load("res://Spells/Shield/shield.tres").duplicate())
	spell_book.add_spell(load("res://Spells/fireball/fireball.tres").duplicate())
	spell_book.add_spell(load("res://Spells/shockwave/shockwave.tres").duplicate())
	spell_book.add_spell(load("res://Spells/light_beam/light_beam.tres").duplicate())
	GlobalDataBus.world_interaction.connect(interact_with_element)
	GlobalDataBus.set_spawn_point.connect(_on_set_spawn_point)
	_on_set_spawn_point(GlobalLevelMap.spawn_point)
	
#func _input(event):
	#if event.is_action_pressed("open_spells_ui"):
		#GlobalDataBus.open_spell_interface.emit(spell_book, GlobalEnums.SPELL_DIALOG_MODES.SHOW)
	
func _unhandled_input(event):
	if event.is_action_pressed("open_spells_ui"):
		GlobalDataBus.open_spell_interface.emit(spell_book, GlobalEnums.SPELL_DIALOG_MODES.SHOW)
	
	if TurnQueueGlobal.turn_mode == false or TurnQueueGlobal.active_char == self:
		match input_state:
			INPUT_STATE.MOVE:
				if event.is_action_pressed("left_mouse_click") == false:
					return
				else:
					if tile_map.local_to_map(get_global_mouse_position()):
						pass
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
	if(TurnQueueGlobal.turn_mode==false):
		call_deferred("turn_modeON")
		#body.call_deferred("turn_modeON");

#UI STUFF
func _on_end_turn_button_pressed():#TODO
	if TurnQueueGlobal.turn_mode:
		TurnQueueGlobal.play_turn()

func _on_attack_button_button_down():#TODO
	if input_state == INPUT_STATE.MOVE:
		input_state = INPUT_STATE.ATTACK
	elif input_state != INPUT_STATE.BLOCK:
		input_state = INPUT_STATE.MOVE
	
func _on_spells_ui_child_entered_tree(node):
	#node.connect("pressed", Callable(self, "_spell_button_pressed").bind(node))
	node.connect("pressed", Callable(self, "_spell_button_pressed").bind(node.spell_resource))

#func _spell_button_pressed(spell_button:SpellButton):
	#current_id_path = [tile_map.local_to_map(global_position)]
	#
	#if input_state == INPUT_STATE.ATTACK and spell_book.get_indexed_spell(spell_button.spell_index) == next_attack:
		#input_state = INPUT_STATE.MOVE
		#next_attack = null
	#else:
		#input_state = INPUT_STATE.ATTACK
		#next_attack = spell_book.get_indexed_spell(spell_button.spell_index)
func _spell_button_pressed(spell_resource:Spell):
	current_id_path = [tile_map.local_to_map(global_position)]
	
	if input_state == INPUT_STATE.ATTACK and spell_resource == next_attack:
		input_state = INPUT_STATE.MOVE
		next_attack = null
	else:
		input_state = INPUT_STATE.ATTACK
		next_attack = spell_resource

func interact_with_element(element:Interactable):
	match element.interaction_type:
		GlobalEnums.INTERACTABLES.CONTAINER:
			element.open_container()
		GlobalEnums.INTERACTABLES.UPGRADE:
			element.on_interaction()
			GlobalDataBus.open_spell_interface.emit(spell_book, GlobalEnums.SPELL_DIALOG_MODES.UPGRADE)
		GlobalEnums.INTERACTABLES.SPELL:
			var new_spell = element.spell
			element.on_interaction()
			GlobalDataBus.open_spell_interface.emit(spell_book, GlobalEnums.SPELL_DIALOG_MODES.ADD_SPELL, new_spell)
		GlobalEnums.INTERACTABLES.HEART:
			element.on_interaction()
			max_health+=25
			take_heal(25)

func _on_set_spawn_point(spawn_point: Vector2i):
	spawn_point = tile_map.map_to_local(spawn_point)
	global_position.x = spawn_point.x
	global_position.y = spawn_point.y

func exit_level():
	pass
	
func die():
	input_state = INPUT_STATE.BLOCK
	GlobalDataBus.player_died.emit()
	
