class_name TurnQueue extends Node
static var all_chars: Array[CharacterBase]
static var active_char: CharacterBase
static var turn_mode = false
static var global_tick: Timer = preload("res://systems/TurnQueue/AutoloadTQ/global_tick.tscn").instantiate()


func _ready():
	add_child(global_tick)
	global_tick.start()

static func play_turn(): #actually stats turn for next character
	if !active_char and all_chars.size()>0:
		active_char = all_chars[0]
		return
	elif all_chars.size()==0:
		end_queue()
		return
	var new_index: int = (all_chars.find(active_char) + 1) %  all_chars.size()
	active_char = all_chars[new_index]
	active_char.play_turn()

static func join_queue(node:CharacterBody2D):
	turn_mode = true
	global_tick.stop()
	if all_chars.has(node) == false:
		all_chars.append(node)

static func end_queue():
	all_chars.clear()
	global_tick.start()
	turn_mode = false
	
static func remove_char(node:CharacterBody2D):
	all_chars.erase(node)
