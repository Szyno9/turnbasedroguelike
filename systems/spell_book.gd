class_name SpellBook
extends RefCounted
var _content:Array[Spell] = []

func add_spell(spell:Spell):
	_content.append(spell)
	GlobalDataBus.spell_book_modified.emit()

func remove_spell(spell:Spell):
	_content.erase(spell)
	GlobalDataBus.spell_book_modified.emit()
	
func swap_spell(spell:Spell, new_spell:Spell):
	if spell.name == new_spell.name:
		spell.upgrade()
		return
	var index = _content.find(spell)
	_content[index] = new_spell
	GlobalDataBus.spell_book_modified.emit()
	

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
