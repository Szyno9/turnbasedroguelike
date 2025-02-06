extends Panel

var opened = false
var mode = GlobalEnums.SPELL_DIALOG_MODES.SHOW

func _input(event):
	if opened == true:
		if event.is_action_pressed("ui_cancel"):
			close_menu()

func _ready():
	GlobalDataBus.open_spell_interface.connect(show_spells)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_spells(spell_book:SpellBook, new_mode:GlobalEnums.SPELL_DIALOG_MODES):
	mode = new_mode
	get_tree().paused = true
	opened = true
	for child in %SpellContainer.get_children():
		child.queue_free()
	visible = true
	var button_pck = preload("res://systems/user_inteface/spell_button.tscn")
	var index = 0
	for spell in spell_book.get_spells():
		var button = button_pck.instantiate()
		button.set_properties(spell, index)
		button.connect("pressed", Callable(self, "_on_spell_button_pressed").bind(button.spell_resource))
		%SpellContainer.add_child(button)
		index+=1
	if mode == GlobalEnums.SPELL_DIALOG_MODES.ADD_SPELL or mode == GlobalEnums.SPELL_DIALOG_MODES.SHOW:
		while index <= 7:
			var button = button_pck.instantiate()
			button.set_properties(Spell.new(), index)
			button.connect("pressed", Callable(self, "_on_spell_button_pressed").bind(button.spell_resource))
			%SpellContainer.add_child(button)
			index+=1
		
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
			pass
