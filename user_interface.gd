extends CanvasLayer
@onready var Player_Character = %Player_Character
@onready var SpellsUI = %SpellsUI


func _ready():
	show_spells()


func show_spells():
	var button_pck = preload("res://Spells/spell_button.tscn")
	for spell in Player_Character.spell_book.get_spells():
		var button = button_pck.instantiate()
		button.set_properties(spell.name, spell.spell_scene)
		Player_Character._on_spells_ui_child_entered_tree(button)
		SpellsUI.add_child(button)
