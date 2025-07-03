extends Node2D

func _ready():
    GlobalDataBus.level_changed.connect(refresh_elements)
    refresh_elements()

func refresh_elements():
    for child in get_children():
        child.queue_free()
    for element in GlobalDataBus.elements:
        #print(element.global_position)
        add_child(element)
