extends CharacterBase

class_name EnemyBase
var ai_processing = false
enum ACTION_TYPE{SHOOT, WALK_FOR_RANGE, HEAL, PASS}

func _ready():
	super()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func patrol(): #TODO PRZEROBIĆ
	if is_moving == false and TurnQueue.turn_mode == false:
		set_id_path(get_random_surrouding_tile())
		is_moving = true


func turn_ai():
	ai_processing = true
	var variants:Dictionary={}
	for spell in spell_book.get_spells():
		if spell.cooldown > 0 and spell.action_cost > actions:
			continue
		var spell_type = spell.type
		match spell_type:
			GlobalEnums.SPELL_TYPE.OFFENSIVE:
				var target = find_closest_enemy()
				if check_spell_range(spell, target.global_position):
					variants[spell.name]={"action": ACTION_TYPE.SHOOT,"spell": spell,"target": target}
				elif speed>0:
					variants[spell.name]={"action": ACTION_TYPE.WALK_FOR_RANGE,"spell": spell,"target": target}
			GlobalEnums.SPELL_TYPE.HEAL: #type of self heal
				var target = find_lowest_health_target()
				if check_spell_range(spell, target.global_position):
					variants[spell.name]={"action": ACTION_TYPE.HEAL,"spell": spell,"target": target}
				elif speed>0:
					variants[spell.name]={"action": ACTION_TYPE.WALK_FOR_RANGE,"spell": spell,"target": target}
	var current_variant = {"action": ACTION_TYPE.PASS,"spell": null,"target": null}
	for spell_name in variants.keys():
		if variants[spell_name]["action"] < current_variant["action"]:
			current_variant = variants[spell_name]
	match current_variant["action"]:
		ACTION_TYPE.SHOOT:
			cast_spell(current_variant["target"].global_position,"hostile",current_variant["spell"])
		ACTION_TYPE.HEAL:
			cast_spell(current_variant["target"].global_position,"hostile",current_variant["spell"])
		ACTION_TYPE.WALK_FOR_RANGE:
			set_id_path(current_variant["target"].map_coords)
			if current_id_path.back() == current_variant["target"].map_coords:
				current_id_path.pop_back()
		ACTION_TYPE.PASS:
			end_turn()
	await get_tree().create_timer(1).timeout
	ai_processing = false

func find_lowest_health_target():
	var target = self
	for entity in TurnQueue.all_chars:
		if entity.is_in_group("hostile") and entity.health<target.health: #groups
			target = entity
	return target

func find_closest_enemy():
	var target
	for entity in TurnQueue.all_chars:
		if entity.is_in_group("ally"):
			target = entity
			break
	for entity in TurnQueue.all_chars:
		if entity.is_in_group("ally") and global_position.distance_to(entity.global_position)<global_position.distance_to(target.global_position): #groups
			target = entity
	return target
	
func find_target(spell:Spell) ->Vector2:
	var temp_target:CharacterBase
	for entity in TurnQueue.all_chars:
		if entity.is_in_group("ally") and check_spell_range(spell, entity.global_position): #groups
			temp_target = entity
	if temp_target != null:
		return temp_target.global_position
	else:
		return self.global_position
		
func choose_spell(): #TODO do przerobienia, mmoże się przyda
	var spell = spell_book.pick_random()
	return spell
