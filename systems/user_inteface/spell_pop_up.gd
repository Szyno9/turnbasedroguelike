extends Control

func spellPopUp(slot:Rect2i, spell_resource:Spell):
	%SpellName.text = str(spell_resource.name)
	if GlobalDataBus.spell_dialog_mode == GlobalEnums.SPELL_DIALOG_MODES.UPGRADE:
		upgradeMode(spell_resource)
	elif GlobalDataBus.spell_dialog_mode == GlobalEnums.SPELL_DIALOG_MODES.ADD_SPELL:
		if GlobalDataBus.disputed_spell.name == spell_resource.name:
			upgradeMode(spell_resource)
		else:
			showMode(spell_resource)
	else:
		showMode(spell_resource)
			
	
	var mouse_pos = get_viewport().get_mouse_position()
	var correction
	var padding = 4
	if mouse_pos.x <= get_viewport_rect().size.x/2:
		correction = Vector2i(slot.size.x + padding, 0)
	else:
		correction = -Vector2i(%SpellPopUpPanel.size.x + padding, 0)
	%SpellPopUpPanel.popup(Rect2i(slot.position + correction, %SpellPopUpPanel.size))

func showMode(spell_resource:Spell):
	%DamageVal.text = str(spell_resource.damage)
	%ActionCostVal.text = str(spell_resource.action_cost)
	%BaseCooldownVal.text = str(spell_resource.basic_cooldown)
	%RemainingCooldownVal.text = str(spell_resource.cooldown)

func upgradeMode(spell_resource:Spell):
	%DamageVal.text = str(spell_resource.damage) + " -> " + str(spell_resource.next_level_damage())
	%ActionCostVal.text = str(spell_resource.action_cost) + " -> " + str(spell_resource.next_level_action_cost())
	%BaseCooldownVal.text = str(spell_resource.basic_cooldown) + " -> " + str(spell_resource.next_level_basic_cooldown())
	%RemainingCooldownVal.text = str(spell_resource.cooldown)  + " -> " + str(spell_resource.cooldown)
	
func hideSpellPopUp():
	%SpellPopUpPanel.hide()
