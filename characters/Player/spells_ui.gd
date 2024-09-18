extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	show_spells()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_spells():
	var button_pck = preload("res://Spells/spell_button.tscn")
	for spell in %SpellBook.spell_array:
		var button = button_pck.instantiate()
		button.set_properties(spell.name, spell.spell_scene)
		%SpellsUI.add_child(button)
