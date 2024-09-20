extends CanvasLayer
@onready var Player_Character: CharacterBase = %Player_Character
@onready var SpellsUI: HBoxContainer = %SpellsUI
#@onready var HPValue: int = %HPValue.text
#@onready var ActionsValue: int = %ActionsValue.text

func _ready():
	show_spells()

func _process(delta):
	if Player_Character.actions == 0: #TODO zmienić do funkcji on_changed
		for button in SpellsUI.get_children():
			button.disabled = true
	else:
		for button in SpellsUI.get_children():
			button.disabled = false
	%HPValue.text = str(Player_Character.health)
	%ActionsValue.text = str(Player_Character.actions)
	%SpeedValue.text = str(Player_Character.speed)
	#if not TurnQueue.all_chars.is_empty():
		#print(TurnQueue.all_chars)
	
func show_spells():
	var button_pck = preload("res://Spells/spell_button.tscn")
	for spell in Player_Character.spell_book.get_spells():
		var button = button_pck.instantiate()
		button.set_properties(spell)
		Player_Character._on_spells_ui_child_entered_tree(button)
		SpellsUI.add_child(button)
