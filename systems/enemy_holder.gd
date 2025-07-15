extends Node2D

func _ready():
	GlobalDataBus.level_changed.connect(refresh_elements)
	refresh_elements()

func refresh_elements():
	for child in get_children():
		#child.queue_free()
		child.call_deferred("queue_free")
	for element in GlobalDataBus.elements:
		#add_child(element)
		call_deferred("add_child",element)

	
