extends Panel

var opened = false
var mode = GlobalEnums.SPELL_DIALOG_MODES.UPGRADE
var spell_book: SpellBook
var next_spell: Spell

func _input(event):
	if opened == true:
		if event.is_action_pressed("ui_cancel"):
			close_menu()

func _ready():
	GlobalDataBus.open_spell_interface.connect(show_spells)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_spells(user_spell_book:SpellBook, new_mode:GlobalEnums.SPELL_DIALOG_MODES, new_spell:Spell = null):
	spell_book = user_spell_book
	mode = new_mode
	next_spell = new_spell
	open_menu()
	for child in %SpellContainer.get_children():
		child.queue_free()
	for child in %NewSpellContainer.get_children():
		child.queue_free()
	
	var button_pck = preload("res://systems/user_inteface/spell_button.tscn")
	var index = 0
	for spell in spell_book.get_spells():
		var button = button_pck.instantiate()
		button.set_properties(spell, index)
		button.connect("pressed", Callable(self, "_on_spell_button_pressed").bind(button.spell_resource))
		%SpellContainer.add_child(button)
		index+=1
	if mode == GlobalEnums.SPELL_DIALOG_MODES.ADD_SPELL:
		var button = button_pck.instantiate()
		button.set_properties(Spell.new(), index)
		button.connect("pressed", Callable(self, "_on_spell_button_pressed").bind(button.spell_resource))
		%SpellContainer.add_child(button)
		index+=1
		
		var button2 = button_pck.instantiate()
		button2.set_properties(new_spell, index)
		%NewSpellContainer.add_child(button2)
		
func open_menu():
	get_tree().paused = true
	opened = true
	visible = true
func close_menu():
	visible = false
	get_tree().paused = false
	opened = false

func _on_spell_button_pressed(spell_resource:Spell):
	match mode:
		GlobalEnums.SPELL_DIALOG_MODES.UPGRADE:
			spell_resource.upgrade()
			close_menu()
		GlobalEnums.SPELL_DIALOG_MODES.SHOW:
			return
		GlobalEnums.SPELL_DIALOG_MODES.ADD_SPELL:
			spell_book.swap_spell(spell_resource, next_spell)
			close_menu()
