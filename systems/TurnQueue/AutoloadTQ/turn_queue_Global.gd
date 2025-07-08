class_name TurnQueue extends Node
var all_chars: Array[CharacterBase]
var active_char: CharacterBase
var turn_mode = false
var global_tick: Timer = preload("res://systems/TurnQueue/AutoloadTQ/global_tick.tscn").instantiate()

func _ready():
	add_child(global_tick)
	global_tick.start()

func _physics_process(delta):
	if all_chars.size()<=1 and turn_mode == true:
		end_queue()
		return

func play_turn(): #actually starts turn for next character
	if !active_char and all_chars.size()>0:
		active_char = all_chars[0]
		return
	elif all_chars.size()<=1:
		end_queue()
		return
	var new_index: int = (all_chars.find(active_char) + 1) %  all_chars.size()
	active_char = all_chars[new_index]
	active_char.play_turn()

func join_queue(node:CharacterBody2D):
	turn_mode = true
	global_tick.stop()
	if all_chars.has(node) == false:
		all_chars.append(node)
		all_chars.sort_custom(initiative_sort)
	else:
		play_turn()

func end_queue():
	all_chars.clear()
	global_tick.timeout.emit()
	global_tick.start()
	turn_mode = false
	
func remove_char(node:CharacterBody2D):
	all_chars.erase(node)

func initiative_sort(a:CharacterBase,b:CharacterBase):
	if a.initiative > b.initiative:
		return true
	return false
	
