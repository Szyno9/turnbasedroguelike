extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalDataBus.open_spell_interface.connect(show_spells)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_spells(spell_book:SpellBook):
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

func _on_spell_button_pressed(spell_resource:Spell):
	spell_resource.upgrade()
	visible = false
