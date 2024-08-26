extends Node

class_name turn_queue
var combat_mode = false
var all_chars: Array
@export var active_char: CharacterBody2D
#func _init():
#	get_chars()
	
func _ready(): #TODO tymczasowe bez main
	get_chars()
	play_turn()

func get_chars():
	all_chars = get_children(false)
	all_chars.sort() #TODO:Sortowanie
	active_char = get_child(0)

func play_turn():
	var new_index: int = (active_char.get_index() + 1) %  get_child_count()
	active_char = get_child(new_index)
	active_char.play_turn()

	
