extends Node

@onready var tile_map:LevelMap


var MAX_ROOM_SIZE: int = 90
var level_grid:Array
var room_table : Array[Array]
var cellular_automata_steps = 4

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

func new_level():
	tile_map = get_parent() #TODO: na ten moment to jest głupie jak but
	
	draw_room(generate_level(), Vector2i(0,0))
	spawn_enemies()
	get_parent().initialize()
	#get_tree().current_scene.add_child(tile_map.duplicate())

func spawn_enemies(amount_of_groups:int = 4, size_of_groups:int = 3):
	var regions_table = []
	var i = 0
	while i < amount_of_groups:
		var new_point = Vector2i(randi_range(0,level_grid[0].size()),randi_range(0,level_grid.size()))
		var new_region = circular_search(new_point, 30, regions_table)
		if new_region != []:
			i+=1
			regions_table.append(new_region)

	var monster_group = load("res://map_elements/monster_groups/evil_mage_skeletons.tres").duplicate()
	for region in regions_table:

		for monster in monster_group.get_monsters():
			var spawn_point = region.pick_random()
			region.erase(spawn_point)
			spawn_point -= Vector2i(MAX_ROOM_SIZE/2, MAX_ROOM_SIZE/2)
			var monster_scene = monster.instantiate()
			monster_scene.global_position = tile_map.map_to_local(spawn_point)
			GlobalDataBus.elements.append(monster_scene)

#func check_point_for_enemy_group(grid, point):
	#circular_search()
	
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
	var offset_x:int = room[0].size()/2
	var offset_y:int = room.size()/2
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
	# Determine room width and height randomly within the specified range
	var room = []
	for y in range(MAX_ROOM_SIZE):
		room.append([])
		for x in range(MAX_ROOM_SIZE):
			if (randf() < 0.45):  # Losowa inicjalizacja: 1 - ściana, 0 - wolna przestrzeń
				room[y].append(1)
			else:
				room[y].append(0)
	
	for i in range(cellular_automata_steps):
		room = cellular_automata(room)
	
	find_sub_rooms(room)
	level_grid = room
	return room

func cellular_automata(room):
	for y in range(MAX_ROOM_SIZE):
		for x in range(MAX_ROOM_SIZE):
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
			if nx >= 0 and ny >= 0 and nx < MAX_ROOM_SIZE and ny < MAX_ROOM_SIZE:
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
			if nx >= 0 and ny >= 0 and nx < MAX_ROOM_SIZE and ny < MAX_ROOM_SIZE:
				count += room[ny][nx]
			else:
				continue
	return count
	
func find_sub_rooms(room: Array):
	var visited:Array = []
	for i in range(MAX_ROOM_SIZE):
		visited.append([])
		for j in range(MAX_ROOM_SIZE):
			visited[i].append(false)
	
	var room_dict = {}
	var start = Vector2i(0,0)
	
	while find_room(room,visited) != null:
		room_dict = find_room(room,visited)
		start = room_dict["Start"]
		visited = room_dict["Visited"]
	
		room_dict = scan_room(room, visited, start)
		visited = room_dict["Visited"]
		room_table.append(room_dict["Subroom"])

			
func find_room(room:Array, visited:Array):
	for y in range(MAX_ROOM_SIZE):
		for x in range(MAX_ROOM_SIZE):
			if y == MAX_ROOM_SIZE - 1 and x == MAX_ROOM_SIZE - 1:
				visited[y][x] = true
				return null
			if room[y][x] == 1 and visited[y][x] == false:
				visited[y][x] = true
			elif room[y][x] == 0 and visited[y][x] == false:
				return {"Start":Vector2i(x,y),"Visited": visited} # room found
	

#BFS for room_grid
func scan_room(room: Array, visited: Array, start: Vector2i):
	var subroom = []
	for y in range(MAX_ROOM_SIZE):
		subroom.append([])
		for x in (MAX_ROOM_SIZE):
			subroom[y].append(1)
			
	var queue: Array[Vector2i] = []
	queue.append(start)
	visited[start.y][start.x] = true
	subroom[start.y][start.x] = 0
	while !queue.is_empty():
		var current: Vector2i = queue.front()
		queue.pop_front()
		for neighbour in [Vector2i(-1, 0),Vector2i(0, -1),Vector2i(1, 0),Vector2i(0, 1)]:
			var dx = current.x + neighbour.x
			var dy = current.y + neighbour.y
			if (dx < 0 or dy < 0 or dx >= MAX_ROOM_SIZE or dy >= MAX_ROOM_SIZE):
				continue
			if room[dy][dx] == 1 or visited[dy][dx] == true:
				continue
			visited[dy][dx] = true
			queue.append(Vector2i(dx,dy))
			subroom[dy][dx] = 0
	return {"Subroom": subroom, "Visited": visited}
	
func slice_room(room: Array):
	var sliced_room = []
	var most_left:int = MAX_ROOM_SIZE
	var most_right:int = 0
	var most_up:int = MAX_ROOM_SIZE
	var most_down:int = 0
	for y in range(room.size()):
		for x in range(room.size()):
			if room[y][x] == 0:
				if x < most_left:
					most_left = x
				if x > most_right:
					most_right = x
				if y < most_up:
					most_up = y
				if y > most_down:
					most_down = y
	var i = 0
	for y in range(most_up, most_down):
		sliced_room.append([])
		for x in range(most_left, most_right):
			sliced_room[i].append(room[y][x])
		i += 1

	return sliced_room
