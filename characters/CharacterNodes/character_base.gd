extends CharacterBody2D

class_name CharacterBase
#enum INPUT_STATE{MOVE, ATTACK}
#var input_state:int
@export_category("Stats")
@export var starting_stats:Stats
@export var health: int
@export var actions: int
@export var speed: int
@export var initiative: int
var spell_book:SpellBook = SpellBook.new()
var next_attack:Spell

@export_category("Safe Values")
@export var is_moving = false
signal move_finished

@export var tile_map:Floor
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
@onready var NotifyArea = preload("res://characters/CharacterNodes/NotifyArea.tscn").instantiate()



func _ready():
	tile_map=$"../TileMapLayer"
	astar_grid = tile_map.astar_grid
	#AStarGrid2D.new()
	#astar_grid.region = tile_map.get_used_rect()
	#astar_grid.cell_size = Vector2(32, 32)
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.update()
	add_child(NotifyArea)
	
	TurnQueue.global_tick.connect("timeout", Callable(self, "_on_global_tick"))
	health = starting_stats.health
	actions = starting_stats.actions
	speed = starting_stats.speed
	initiative = starting_stats.initiative
	
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
			
func _physics_process(delta):
	pass
	
#TURN FUNCTIONS
func play_turn():
	turn_tick()
	
func end_turn():
	TurnQueue.play_turn()
	
func _on_global_tick():
	if TurnQueue.turn_mode == false:
		turn_tick()

func turn_modeON(): #TODO: lepsze szukanie wrogów do kolejki
	if TurnQueue.turn_mode == false:
		TurnQueue.turn_mode=true
		TurnQueue.join_queue(self)
		TurnQueue.play_turn()
	for entity in NotifyArea.get_overlapping_bodies():
		#entity.call_deferred("turn_modeON")
		TurnQueue.join_queue(entity)


func turn_modeOff():
	#TurnQueue.turn_mode = false
	TurnQueue.end_queue()
	
func turn_tick(): #TODO
	if TurnQueue.turn_mode == true:
		current_id_path.clear()
		is_moving = false
	speed=starting_stats.speed
	actions=starting_stats.actions
	spell_book.turn_tick()
	
	
#BASE FUNCTIONS
func take_damage(damage:int):
	if TurnQueue.turn_mode == false:
		turn_modeON()
	health-=damage
	if health <=0:
		TurnQueue.remove_char(self)
		queue_free()
		
func cast_spell(target:Vector2, protected_group: String, spell: Spell): #TODO zmiana attack na Resource
	actions-=spell.action_cost
	spell_book.set_cooldown(spell)
	var b = spell.spell_scene.instantiate()
	b.target = tile_map.map_to_local(tile_map.local_to_map(target))
	b.protected_group = protected_group
	b.transform = global_transform
	b.damage = spell.damage
	add_sibling(b)

func set_id_path(target:Vector2i):
	var id_path
	if current_id_path.is_empty():
		id_path = astar_grid.get_id_path(tile_map.local_to_map(global_position), target).slice(1)
	else:
		id_path = astar_grid.get_id_path(current_id_path.front(), target)
	if id_path.is_empty() == false:
		current_id_path = id_path
func move_path():
	if current_id_path.is_empty() == false and speed>0:
		is_moving = true
		var next_tile = tile_map.map_to_local(current_id_path.front())
		global_position = global_position.move_toward(next_tile, 3)
		if global_position == next_tile:
			if TurnQueue.turn_mode:
				speed-=1
			current_id_path.pop_front()
			move_finished.emit()
	else:
		is_moving = false

func get_random_surrouding_tile():
	var surround_table = tile_map.get_surrounding_cells(tile_map.local_to_map(global_position))
	for tile in surround_table:
		if astar_grid.is_point_solid(tile):
			surround_table.erase(tile)
	return surround_table[randi_range(0,surround_table.size()-1)]

#func move_one_tile(direction):
	#if speed > 0:	
		#global_position = global_position.move_toward(tile_map.map_to_local((direction)), 1)	
		#if tile_map.map_to_local(direction) == global_position:
			#is_moving = false
			#emit_signal("move_finished")
			#if TurnQueue.turn_mode:
				#speed-=1
#

			#
#func set_id_path(target_location: Vector2i):
	#var id_path = astar_grid.get_id_path(
				#tile_map.local_to_map(global_position),
				#target_location
			#).slice(1)
	#if id_path.is_empty() == false:
		#current_id_path = id_path
#
#func move_to_tile():
	#if current_id_path.is_empty():
		#return
	#var target = current_id_path.front()
	#
	#if speed > 0:	
		#global_position = global_position.move_toward(tile_map.map_to_local((target)), 1)
		#if global_position == tile_map.map_to_local(target):
			#tile_map._character_moved(target, Vector2i(0,0))
			#current_id_path.pop_front()
			#if TurnQueue.turn_mode:
				#speed-=1
		#if current_id_path.is_empty():
			#is_moving = false
			#emit_signal("move_finished")
			
	
func find_target() ->Vector2:
	var temp_target:CharacterBase
	for entity in NotifyArea.get_overlapping_bodies():
		if entity.is_in_group("ally"): #groups
			temp_target = entity
	if temp_target != null:
		return temp_target.global_position
	else:
		return self.global_position
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
