extends Node

@onready var tile_map:LevelMap

var level_patterns_group:ResourceGroup = load("res://assets/level_patterns/level_patterns_group.tres")
var level_patterns = level_patterns_group.load_all()
var MAX_ROOM_SIZE: int = 90
var level_grid:Array
var room_table : Array[Array]
@export var apply_noise_steps = 2
@export var cellular_automata_steps = 3

var debug_position = Vector2i(0,0)

signal level_generated

#func _ready():
	#tile_map = %LevelMap
	##generate_level() Done
	##find_sub_rooms() Done
	##draw_room() Done
	#
	#draw_room(generate_level(), Vector2i(0,0))
	##circular_search(level_grid,Vector2i(25,25), 2)
	#spawn_enemies()
	#tile_map.initialize()

#func _ready():
	#tile_map = get_parent() #TODO: na ten moment to jest głupie jak but
	##generate_level()
	#draw_room(generate_level(),Vector2i(0,0))
	#get_parent().initialize()

func new_level():
	tile_map = get_parent() #TODO: na ten moment to jest głupie jak but
	
	draw_room(generate_level(), Vector2i(0,0))
	get_parent().initialize()


func spawn_enemies(encounter_coords:Vector2i):
	var viable_monster_groups:Array
	for group in GlobalDataBus.all_enemy_groups:
		if group.map_levels.has(GlobalDataBus.current_level):
			viable_monster_groups.append(group)
	var monster_group = viable_monster_groups.pick_random()
	var spawn_area: Array[Vector2i] = get_spawn_area(encounter_coords, monster_group.get_monsters().size())
	
	for monster in monster_group.get_monsters():
		var spawn_point = spawn_area.pick_random()
		if spawn_area.size()>1:
			spawn_area.erase(spawn_point)
		var monster_scene = monster.instantiate()
		monster_scene.global_position = tile_map.map_to_local(spawn_point)
		GlobalDataBus.elements.append(monster_scene)

func get_spawn_area(center_coords:Vector2i, monster_group_size:int) -> Array[Vector2i]:
	const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	var spawn_area: Array[Vector2i] = []
	var cell_stack: Array = [center_coords]
	while not (cell_stack.is_empty()):
		#if spawn_area.size()>=monster_group_size*2:
			#break
		var current = cell_stack.pop_back()
		if current in spawn_area:
			continue
		
		spawn_area.append(current)
		
		for direction in DIRECTIONS:
			var cell: Vector2i = current + direction
			if cell.y>=level_grid.size() or cell.y<0 or cell.x>=level_grid[0].size() or cell.x<0:
				continue
			if cell in spawn_area:
				continue
			if level_grid[cell.y][cell.x] == 1:
				continue
			if cell.distance_to(center_coords) >= monster_group_size:
				continue
			cell_stack.append(cell)
	return spawn_area

func spawn_treasures(treasure_coords:Vector2i):
	var chest = load("res://map_elements/Chest/chest.tscn").instantiate()
	chest.global_position = tile_map.map_to_local(treasure_coords)
	GlobalDataBus.elements.append(chest)
	
func spawn_level_exit(exit_coords:Vector2i):
	var exit = load("res://map_elements/level_exit/level_exit.tscn").instantiate()
	exit.global_position = tile_map.map_to_local(exit_coords)
	GlobalDataBus.elements.append(exit)
	
func circular_search(center, region_size, region_table):
	var grid = level_grid
	const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	var current_region = []
	var cell_stack: Array = [center]
	while not (cell_stack.is_empty()):
		if current_region.size()>=region_size:
			break
		var current = cell_stack.pop_back()
		if current in current_region:
			continue
		if check_existing_regions(current, region_table):
			continue
		
		current_region.append(current)
		
		for direction in DIRECTIONS:
			var cell: Vector2i = current + direction
			if cell.y>=grid.size() or cell.y<0 or cell.x>=grid[0].size() or cell.x<0:
				continue
			if cell in current_region:
				continue
			if grid[cell.y][cell.x] == 1:
				continue
			cell_stack.append(cell)
	if current_region.size()>=region_size:
		return current_region
	return []

func check_existing_regions(current, region_table):
	for existing_region in region_table:
		if current in existing_region:
			return true
	return false

func draw_room(room:Array, starting_point:Vector2i):
	var walls:Array[Vector2i]
	var floors:Array[Vector2i]
	var offset_x:int = 0#room[0].size()/2
	var offset_y:int = 0#room.size()/2
	var room_cells:Array[Vector2i]
	for y in range(room.size()):
		for x in range(room[y].size()):
			var tile_position = Vector2i(starting_point.x + x-offset_x, starting_point.y + y-offset_y)
			room_cells.append(tile_position)
			if room[y][x] == 0:
				floors.append(tile_position)
			else:
				walls.append(tile_position)
	
	BetterTerrain.set_cells(tile_map,0,walls,1)
	BetterTerrain.set_cells(tile_map,0,floors,0)
	BetterTerrain.update_terrain_cells(tile_map,0,room_cells, true)
	
	
# ROOM PART
func generate_level():
	var room_properties: Array = []
	var encounters_coords_table = []
	var treasure_coords_table = []
	var patchs:Image = level_patterns.pick_random()#load("res://assets/level_patterns/Sprite-0003.png")
	
	#if patchs.get_format() != Image.FORMAT_RGBA8:
		#patchs.convert(Image.FORMAT_RGBA8)
	
	
	for column in range(patchs.get_height()):
		room_properties.append([])
		for row in range(patchs.get_width()):
			if patchs.get_pixel(row, column) == Color(0,0,0,0):
				room_properties[column].append(1) #Wall
			elif patchs.get_pixel(row, column) == Color(0,0,0,1):
				room_properties[column].append(0) #Floor
			elif patchs.get_pixel(row, column) == Color(1,0,0,1):
				room_properties[column].append(2) #Encounter
				encounters_coords_table.append(Vector2i(row, column))
			elif patchs.get_pixel(row, column) == Color(0,1,0,1):
				treasure_coords_table.append(Vector2i(row, column))
				room_properties[column].append(3) #Tresure
			elif patchs.get_pixel(row, column) == Color(0,1,1,1):
				get_parent().spawn_point = Vector2i(row, column)
				room_properties[column].append(5) #Spawn point
			elif patchs.get_pixel(row, column) == Color(1,1,1,1):
				spawn_level_exit(Vector2i(row, column))
				room_properties[column].append(4) #Exit

	var room := room_properties.duplicate(true)
	
	
	
	for column in range(room.size()):
		for row in range(room[0].size()):
			if room[column][row] != 0 and room[column][row] != 1:
				room[column][row] = 0
	for i in range(apply_noise_steps):
		room = apply_noise(room)
	
	
	for i in range(cellular_automata_steps):
		room = cellular_automata(room)
	for column in range(room_properties.size()):
		for row in range(room_properties[0].size()):
			if room_properties[column][row] != 1:
				room[column][row] = 0
	
	#find_sub_rooms(room)
	level_grid = room
	
	for treasure_coords in treasure_coords_table:
		spawn_treasures(treasure_coords)
	
	for encounter_coords in encounters_coords_table:
		spawn_enemies(encounter_coords)

	return room

func apply_noise(room):
	var new_room = room
	var noise = []
	for y in range(room.size()): #MAKE NOISE
		noise.append([])
		for x in range(room[0].size()):
			if (randf() < 0.45):  # Losowa inicjalizacja: 1 - ściana, 0 - wolna przestrzeń
				noise[y].append(1)
			else:
				noise[y].append(0)
	for y in range(room.size()):
		for x in range(room[0].size()):
			if noise[y][x] == 0 and noise_logic(room, x, y):
				#room = merge_noise(noise,room,Vector2i(x,y))
				new_room[y][x] = 0
	return new_room

func noise_logic(room, x, y):
	for neighbour in [Vector2i(-1, 0),Vector2i(0, -1),Vector2i(1, 0),Vector2i(0, 1)]:
		var dx = x + neighbour.x
		var dy = y + neighbour.y
		if dx < 0 or dy < 0 or dx >= room[0].size() or dy >= room.size():
			continue
		if room[dy][dx]== 0:
			return true
	return false

func cellular_automata(room):
	for y in range(room.size()):
		for x in range(room[0].size()):
			#if x == 0 or y == 0 or x == MAX_ROOM_SIZE -1 or y == MAX_ROOM_SIZE - 1:
				#room[x][y] = 1;
			#else:
				room[y][x] = PlaceWallLogic(room, x, y)
	return room

func PlaceWallLogic(room, x, y):
	if adjacent_wall_count(room, x, y) >= 5:# or nearby_wall_count(room, x, y) <= 4
		return 1
	else:
		return 0

func adjacent_wall_count(room: Array, x: int, y: int):
	var count = 0
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and ny >= 0 and nx < room[0].size() and ny < room.size():
				count += room[ny][nx]
			else:
				count +=1
	return count

func nearby_wall_count(room, x, y):
	var count = 0
	for dy in [-2, 1, 0, 1, 2]:
		for dx in [-2, 1, 0, 1, 2]:
			if abs(dx) == 0 and abs(dy) == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and ny >= 0 and nx < room[0].size() and ny < room.size():
				count += room[ny][nx]
			else:
				continue
	return count
	
#func find_sub_rooms(room: Array):
	#var visited:Array = []
	#for i in range(MAX_ROOM_SIZE):
		#visited.append([])
		#for j in range(MAX_ROOM_SIZE):
			#visited[i].append(false)
	#
	#var room_dict = {}
	#var start = Vector2i(0,0)
	#
	#while find_room(room,visited) != null:
		#room_dict = find_room(room,visited)
		#start = room_dict["Start"]
		#visited = room_dict["Visited"]
	#
		#room_dict = scan_room(room, visited, start)
		#visited = room_dict["Visited"]
		#room_table.append(room_dict["Subroom"])

			
#func find_room(room:Array, visited:Array):
	#for y in range(MAX_ROOM_SIZE):
		#for x in range(MAX_ROOM_SIZE):
			#if y == MAX_ROOM_SIZE - 1 and x == MAX_ROOM_SIZE - 1:
				#visited[y][x] = true
				#return null
			#if room[y][x] == 1 and visited[y][x] == false:
				#visited[y][x] = true
			#elif room[y][x] == 0 and visited[y][x] == false:
				#return {"Start":Vector2i(x,y),"Visited": visited} # room found
	


	
#func slice_room(room: Array):
	#var sliced_room = []
	#var most_left:int = MAX_ROOM_SIZE
	#var most_right:int = 0
	#var most_up:int = MAX_ROOM_SIZE
	#var most_down:int = 0
	#for y in range(room.size()):
		#for x in range(room.size()):
			#if room[y][x] == 0:
				#if x < most_left:
					#most_left = x
				#if x > most_right:
					#most_right = x
				#if y < most_up:
					#most_up = y
				#if y > most_down:
					#most_down = y
	#var i = 0
	#for y in range(most_up, most_down):
		#sliced_room.append([])
		#for x in range(most_left, most_right):
			#sliced_room[i].append(room[y][x])
		#i += 1
#
	#return sliced_room
