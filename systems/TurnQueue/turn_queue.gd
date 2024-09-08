#extends Node

class_name turn_queue extends Node
var all_chars: Array
signal turn_mode_start
@export var active_char: CharacterBody2D
	
func get_chars():
	all_chars = get_children(false)
	all_chars.sort() #TODO:Sortowanie
	if all_chars.size() > 0:
		active_char = get_child(0)
		
func get_char(node):
	all_chars.append(node)
	all_chars.sort() #TODO:Sortowanie

func play_turn():
	if !active_char:
		active_char = get_child(0) 
	var new_index: int = (active_char.get_index() + 1) %  get_child_count()
	active_char = get_child(new_index)
	
	active_char.play_turn()

func _on_child_entered_tree(node):
	get_char(node)

func _on_turn_mode_start():
	all_chars.sort()
	active_char = get_child(0)
	active_char.play_turn()
