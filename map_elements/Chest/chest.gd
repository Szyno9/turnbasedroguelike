extends Interactable

class_name Chest

var opened: bool = false
var content = load("res://map_elements/SpellUpgrade/spell_upgrade.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open_chest():
	opened = true
	$Sprite2D.frame=1
	var upgrade = content.instantiate()
	upgrade.global_position = get_global_position()
	add_sibling(upgrade)


func _on_area_2d_input_event(viewport, event, shape_idx):
	if opened == true:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			GlobalDataBus.world_interaction.emit(self)
