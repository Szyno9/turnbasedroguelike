class_name SpellBook
extends RefCounted
var _content:Array[Spell] = []


func add_spell(spell:Spell):
	_content.append(spell)

func remove_spell(spell:Spell):
	_content.erase(spell)

func get_spells() -> Array[Spell]:
	return _content
	

func pick_random() -> Spell:
	var temp:Array[Spell]
	for spell in _content:
		if spell.cooldown==0:
			temp.append(spell)
	return temp.pick_random()

func get_indexed_spell(index:int) -> Spell:
	return _content[index]

func set_cooldown(spell:Spell):
	_content[_content.find(spell)].cooldown = spell.basic_cooldown

func turn_tick():
	for spell in _content:
		if spell.cooldown>0:
			spell.cooldown-=1
