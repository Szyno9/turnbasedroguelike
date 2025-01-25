extends Button

class_name SpellButton
# Called when the node enters the scene tree for the first time.
var spell_index:int
var spell_resource:Spell

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_properties(spell_resource1:Spell, spell_index1:int):
	icon=spell_resource1.icon
	#text=spell_resource1.name
	spell_index = spell_index1
	spell_resource = spell_resource1
