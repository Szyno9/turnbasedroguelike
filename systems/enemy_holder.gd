extends Node2D

func _ready():
	#GlobalDataBus.element_holder = self
	for element in GlobalDataBus.elements:
		print(element.global_position)
		add_child(element)

func clear_elements():
	for child in get_children():
		child.queue_free()
