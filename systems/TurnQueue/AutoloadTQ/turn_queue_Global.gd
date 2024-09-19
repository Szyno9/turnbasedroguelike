class_name TurnQueue extends Node
static var all_chars: Array
static var active_char: CharacterBody2D
static var turn_mode = false

static func play_turn():
	if !active_char:
		active_char = all_chars[0]
	var new_index: int = (all_chars.find(active_char) + 1) %  all_chars.size()
	active_char = all_chars[new_index]
	active_char.play_turn()

static func join_queue(node:CharacterBody2D):
	turn_mode = true
	if all_chars.has(node) == false:
		all_chars.append(node)
	print(all_chars)

static func end_queue():
	all_chars.clear()
	turn_mode = false
	
static func remove_char(node:CharacterBody2D):
	all_chars.erase(node)
