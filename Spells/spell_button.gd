extends Button

class_name SpellButton
# Called when the node enters the scene tree for the first time.
var spell_index:int


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_properties(spell_resource1:Spell, spell_index1:int):
	text=spell_resource1.name
	spell_index = spell_index1
