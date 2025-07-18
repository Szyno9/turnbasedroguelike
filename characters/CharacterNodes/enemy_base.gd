extends CharacterBase

class_name EnemyBase
var ai_processing = false
var central_patrol_point:Vector2i = Vector2i.ZERO
enum ACTION_TYPE{SHOOT, WALK_FOR_RANGE, HEAL, PASS}

@export var basic_level: int
@export var spell_list: Array[Spell]

func _ready():
	super()
	learn_spells()
	adjust_to_level()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func patrol():
	await get_tree().create_timer(randf_range(0,1.5)).timeout
	if central_patrol_point == Vector2i.ZERO:
		central_patrol_point = tile_map.local_to_map(global_position)
	if is_moving == false and TurnQueueGlobal.turn_mode == false:
		var random_tile = get_random_surrouding_tile()
		if random_tile.distance_to(central_patrol_point) > 5:
			set_id_path(central_patrol_point)
		else:
			set_id_path(random_tile)
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
			if variants[spell_name]["spell"].action_cost > actions:
				continue
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
	for entity in TurnQueueGlobal.all_chars:
		if entity.is_in_group("hostile") and entity.health<target.health: #groups
			target = entity
	return target

func find_closest_enemy():
	var target
	for entity in TurnQueueGlobal.all_chars:
		if entity.is_in_group("ally"):
			target = entity
			break
	for entity in TurnQueueGlobal.all_chars:
		if entity.is_in_group("ally") and global_position.distance_to(entity.global_position)<global_position.distance_to(target.global_position): #groups
			target = entity
	return target
	
func find_target(spell:Spell) ->Vector2:
	var temp_target:CharacterBase
	for entity in TurnQueueGlobal.all_chars:
		if entity.is_in_group("ally") and check_spell_range(spell, entity.global_position): #groups
			temp_target = entity
	if temp_target != null:
		return temp_target.global_position
	else:
		return self.global_position
		
func choose_spell(): #TODO do przerobienia, mmoże się przyda
	var spell = spell_book.pick_random()
	return spell

func give_rewards():
	pass

func learn_spells():
	for spell in spell_list:
		var new_spell = spell.duplicate()
		for i in range(0, GlobalDataBus.current_level):
			new_spell.upgrade()
		spell_book.add_spell(new_spell)
		
func adjust_to_level():
	for i in range(0, GlobalDataBus.current_level - basic_level):
		max_health=floori(max_health*1.25)
		health = max_health
		max_speed+=1
		speed=max_speed
