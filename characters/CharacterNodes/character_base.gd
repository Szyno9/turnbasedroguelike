extends CharacterBody2D

class_name CharacterBase
#enum INPUT_STATE{MOVE, ATTACK}
#var input_state:int

@export_category("Stats")
@export var starting_stats:Stats
@export var max_health: int
@export var health: int
@export var actions: int
@export var speed: int
@export var initiative: int
var spell_book:SpellBook = SpellBook.new()
var next_attack:Spell


@export_category("Safe Values")
@export var is_moving = false
var direction_facing = Vector2i.DOWN
signal move_finished
signal character_damaged
signal character_died
signal spell_casted

@export var tile_map:LevelMap
var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
@onready var NotifyArea:Area2D = preload("res://characters/CharacterNodes/NotifyArea.tscn").instantiate()
@onready var status_holder:StatusHolder = preload("res://characters/CharacterNodes/status_holder.tscn").instantiate()
var map_coords:Vector2i


func _ready():
	tile_map= GlobalLevelMap#%LevelMap #TODO: zrobić to mądrze
	astar_grid = GlobalLevelMap.astar_grid
	add_child(NotifyArea)
	add_child(status_holder)
	
	TurnQueueGlobal.global_tick.connect("timeout", Callable(self, "_on_global_tick"))
	GlobalDataBus.level_changed.connect(_on_level_changed)
	max_health = starting_stats.health
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
			
func _physics_process(_delta):
	map_coords = tile_map.local_to_map(global_position)
	pass
	
#TURN FUNCTIONS
func play_turn():
	turn_tick()
	
func end_turn():
	TurnQueueGlobal.play_turn()
	
func _on_global_tick():
	if TurnQueueGlobal.turn_mode == false:
		turn_tick()

func turn_modeON(): #TODO: lepsze szukanie wrogów do kolejki
	if TurnQueueGlobal.turn_mode == false:
		TurnQueueGlobal.turn_mode=true
		#TurnQueue.join_queue(self)
	for entity in NotifyArea.get_overlapping_bodies():
		if entity.is_class("CharacterBody2D"):
			TurnQueueGlobal.join_queue(entity)
	await get_tree().create_timer(0.5).timeout
	TurnQueueGlobal.play_turn()


func turn_modeOff():
	#TurnQueue.turn_mode = false
	TurnQueueGlobal.end_queue()
	
func turn_tick(): #TODO
	if TurnQueueGlobal.turn_mode == true:
		current_id_path.clear()
		is_moving = false
	speed=starting_stats.speed
	actions=starting_stats.actions
	spell_book.turn_tick()
	status_holder.turn_tick_status_check()

	
#BASE FUNCTIONS
func take_damage(damage:int):
	if TurnQueueGlobal.turn_mode == false:
		turn_modeON()
	
	damage = status_holder.damage_status_check(damage)
	if damage > 0:
		character_damaged.emit()
		health-=damage
	if health <=0:
		die()

func die():
	if TurnQueueGlobal.active_char == self:
		end_turn()
	TurnQueueGlobal.remove_char(self)
	character_died.emit()
	queue_free()

func take_heal(heal:int):
	if heal+health < max_health:
		health+=heal
	else:
		health = max_health
		
func cast_spell(target:Vector2, protected_group: String, spell: Spell):
	if spell.action_cost> actions:
		return
	current_id_path =[]
	actions-=spell.action_cost
	spell_book.set_cooldown(spell)
	
	var b = spell.spell_scene.instantiate()
	b.target = tile_map.map_to_local(tile_map.local_to_map(target))
	b.protected_group = protected_group
	b.transform = global_transform
	b.damage = spell.damage
	
	spell_casted.emit()
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
		global_position = global_position.move_toward(next_tile, 1)
		direction_facing = current_id_path.front() - tile_map.local_to_map(global_position)
		if global_position == next_tile:
			if TurnQueueGlobal.turn_mode:
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


func check_spell_range(spell:Spell, target:Vector2):
	var center:Vector2i = tile_map.local_to_map(global_position)
	var final_target:Vector2i = tile_map.local_to_map(target)
	match(spell.range_type):
		GlobalEnums.RANGE_TYPE.CIRCURAL:
			if center.distance_to(final_target) <= spell.spell_range:
				return true
		GlobalEnums.RANGE_TYPE.LINE:
			if final_target.x == map_coords.x or final_target.y == map_coords.y:
				return true
	return false

func teleport_to_location(destination: Vector2i):
	current_id_path = []
	global_position = destination

func _on_level_changed():
	current_id_path.clear()
	astar_grid = GlobalLevelMap.astar_grid
