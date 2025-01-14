extends CanvasLayer
@onready var Player_Character: CharacterBase = %Player_Character
@onready var SpellsUI: HBoxContainer = %SpellsUI
@onready var camera: Camera2D = $Camera2D
#@onready var Overlay_TileMap: TileMapLayer = %Overlay
#@onready var HPValue: int = %HPValue.text
#@onready var ActionsValue: int = %ActionsValue.text

func _ready():
	show_spells()

func _process(_delta):
	if TurnQueue.turn_mode == false:
		camera.set_position(Player_Character.global_position)
	elif TurnQueue.active_char !=null:
		camera.set_position(TurnQueue.active_char.global_position)
	
	if Player_Character == null:
		return
	if Player_Character.actions == 0 or (TurnQueue.turn_mode == true and Player_Character != TurnQueue.active_char): #TODO zmienić do funkcji on_changed
		for button in SpellsUI.get_children():
			button.disabled = true
	else:
		for button in SpellsUI.get_children():
			if Player_Character.spell_book.get_indexed_spell(button.spell_index).cooldown==0:
				button.disabled = false
			else:
				button.disabled = true
	%HPValue.text = str(Player_Character.health)
	%ActionsValue.text = str(Player_Character.actions)
	%SpeedValue.text = str(Player_Character.speed)
	
func show_spells():
	var button_pck = preload("res://systems/user_inteface/spell_button.tscn")
	var index = 0
	for spell in Player_Character.spell_book.get_spells():
		var button = button_pck.instantiate()
		button.set_properties(spell, index)
		Player_Character._on_spells_ui_child_entered_tree(button)
		SpellsUI.add_child(button)
		index+=1
