extends CharacterBody2D

class_name PlayerBase
#enum INPUT_STATE{MOVE, ATTACK}
#var input_state:int
@export var turn_queue:turn_queue
@export var tile_map:TileMapLayer
@export var stats:Stats
var turn_mode = false
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var spell_book:SpellBook = SpellBook.new()
var next_attack:PackedScene

#func _ready():
	#astar_grid = AStarGrid2D.new()
	#astar_grid.region = tile_map.get_used_rect()
	#astar_grid.cell_size = Vector2(32, 32)
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.update()
	#spell_book.add_spell(load("res://Spells/missle/missle.tres"))
	#
	#turn_queue=%turn_queue
	
#func _unhandled_input(event):
	#match input_state:
		#INPUT_STATE.MOVE:
			#if event.is_action_pressed("left_mouse_click") == false:
				#return
			#var id_path = astar_grid.get_id_path(
				#tile_map.local_to_map(global_position),
				#tile_map.local_to_map((get_global_mouse_position()))
			#).slice(1)
			#
			#if id_path.is_empty() == false:
				#current_id_path = id_path
		#INPUT_STATE.ATTACK:
			#if event.is_action_pressed("left_mouse_click"):
				#var b = next_attack.instantiate()
				#b.target = get_global_mouse_position()
				#b.global_position = Vector2(0,0)
				##owner.add_child(b) #TODO:spawn w mainie
				#add_child(b)
				#b.transform = global_transform
			
#func _physics_process(delta):
	#if Input.is_action_pressed("ui_focus_next"):#TODO
			#turn_queue.turn_mode_start.emit()
	#
	#if current_id_path.is_empty():
		#return
		#
	#var target_position = tile_map.map_to_local(current_id_path.front())
#
	#global_position = global_position.move_toward(target_position, 3)
#
	#if global_position == target_position:
		#current_id_path.pop_front()
	

func play_turn():
	pass
	
func end_turn():
	turn_queue.play_turn()

func turn_modeON():
	if turn_mode == false:
		turn_mode=true
		var new_parent = get_node(turn_queue.get_path())
		get_parent().remove_child(self)
		new_parent.add_child(self)

func _on_area_2d_body_entered(body):
	if(turn_mode==false):
		call_deferred("turn_modeON")
		body.call_deferred("turn_modeON");

func _on_end_turn_button_pressed():#TODO
	turn_queue.play_turn()
	
func take_damage(damage:int):
	call_deferred("turn_modeON")
	stats.health-=damage
	if stats.health <=0:
		queue_free()

#func _on_attack_button_button_down():#TODO
	#if input_state == INPUT_STATE.MOVE:
		#input_state = INPUT_STATE.ATTACK
	#else:
		#input_state = INPUT_STATE.MOVE
	


#func _on_spells_ui_child_entered_tree(node):
	#node.connect("pressed", Callable(self, "_spell_button_pressed").bind(node))

#func _spell_button_pressed(node):
	#if input_state == INPUT_STATE.MOVE:
		#input_state = INPUT_STATE.ATTACK
		#next_attack = node.spell_scene
		#print(node.spell_scene)
	#else:
		#input_state = INPUT_STATE.MOVE
