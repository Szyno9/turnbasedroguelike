extends Node

@onready var tile_map:LevelMap

var connection_graph:Graph
var ROOM_NUMBER: int = 30
var MAX_ROOM_SIZE: int = 90
var STANDARD_GAP: int = 3
var GRID_SIZE: int = MAX_ROOM_SIZE * ROOM_NUMBER

var room_table : Array[Array]
var cellular_automata_steps = 4

var debug_position = Vector2i(0,0)

func _ready():
	tile_map = %LevelMap
	#generate_level() Done
	#find_sub_rooms() Done
	#draw_room() Done
	#place_features()
	draw_room(generate_level(), Vector2i(0,0))
	tile_map.initialize()


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
