extends Node

@onready var tile_map = $TileMapLayer
var floor_tile := Vector2i(0,0)
var wall_tile := Vector2i(1,0)

var connection_graph:Graph
var ROOM_NUMBER: int = 9
var MAX_ROOM_SIZE: int = 30
var GRID_SIZE: int = MAX_ROOM_SIZE * ROOM_NUMBER

var room_table : Array[Array]
var cellular_automata_steps = 9

func _ready():
	#var siema = Vector2i(1,1)
	#var table : Array[Array] = [[0,0],[1,1]]
	#print(table.any(table.has)
	randomize()
	generate_connection_graph(9)
	#connection_graph.print_graph()
	#connection_graph.bfs()
	#connection_graph.djikstra()
	
	draw_room(generate_room())
	#generate_dungeon()
	


###### DUNGEON PART
func generate_dungeon():
	for i in ROOM_NUMBER:
		room_table.append(generate_room())
	
	for room in room_table:
		draw_room(room)

func draw_room(room:Array):
	for y in range(room.size()):
		for x in range(room[y].size()):
			var tile_position = Vector2i(x, y)
			if room[y][x] == 0:
				tile_map.set_cell(tile_position,0,floor_tile)
			else:
				tile_map.set_cell(tile_position, 0, wall_tile)
				
func place_room(room: Array): #for grid usability
	pass
###### ROOM PART
func generate_room():
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
	
	#for i in range(MAX_ROOM_SIZE):
		#print(room[i])
	room = ensure_room_connectivity(room)
	room = slice_room(room)
		
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
	
func ensure_room_connectivity(room: Array):
	var subrooms:Array[Array] = []
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
		subrooms.append(room_dict["Subroom"])

	var largest_count = 0
	for subroom in subrooms:
		var sub_count = 0
		for row in subroom:
			sub_count += row.count(0)
		if sub_count > largest_count:
			largest_count = sub_count
			room = subroom
		
	return room
			
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
	var most_up:int = 0
	var most_down:int = MAX_ROOM_SIZE
	for y in range(room.size()):
		for x in range(room.size()):
			if room[y][x] == 0:
				if x < most_left:
					most_left = x
				if x > most_right:
					most_right = x
				if y > most_down:
					most_down = y
				if y < most_up:
					most_up = y
	var room_center:Vector2i = Vector2i(most_right-most_left, most_down-most_up)
	for y in range(most_up, most_down):
		sliced_room.append([])
		for x in range(most_left, most_right):
			sliced_room[y].append(room[y][x])
	for row in sliced_room:
		print(row)
	return sliced_room
####### GRAPH PART
func generate_connection_graph(room_count:int):
	connection_graph = Graph.new(room_count)
