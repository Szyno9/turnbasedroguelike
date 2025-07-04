extends Resource

class_name Spell

#@export_group("Spell Characteristics") TODO
@export var name:String
@export var icon:Texture
@export var damage: int
@export var basic_cooldown:int
@export var cooldown: int
@export var spell_range:int
@export var range_type:GlobalEnums.RANGE_TYPE
@export var type:GlobalEnums.SPELL_TYPE
#@export var description: String
@export var action_cost: int
@export var spell_scene:PackedScene
@export var upgrade_list:Array[SpellStats]
var current_tier: int = 0

func upgrade():
	current_tier += 1
	var next_upgrade:SpellStats = upgrade_list.front()
	if upgrade_list.size() > 1:
		upgrade_list.pop_front()
	damage+=next_upgrade.damage
	basic_cooldown -= next_upgrade.basic_cooldown
	action_cost -= next_upgrade.action_cost
	spell_range += next_upgrade.spell_range

func next_level_damage():
	return damage+upgrade_list.front().damage

func next_level_basic_cooldown():
	return basic_cooldown - upgrade_list.front().basic_cooldown

func next_level_action_cost():
	return action_cost - upgrade_list.front().action_cost

func next_level_spell_range():
	return spell_range + upgrade_list.front().spell_range
