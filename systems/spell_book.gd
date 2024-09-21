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
	return _content.pick_random()
