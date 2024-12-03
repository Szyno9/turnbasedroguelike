extends Node

@onready var tile_map = $TileMapLayer
var floor_tile := Vector2i(0,0)
var wall_tile := Vector2i(1,0)

var connection_graph:Graph
var ROOM_NUMBER: int = 200
var MAX_ROOM_SIZE: int = 20
var STANDARD_GAP: int = 3
var GRID_SIZE: int = MAX_ROOM_SIZE * ROOM_NUMBER

var room_table : Array[Array]
var cellular_automata_steps = 9

var debug_position = Vector2i(0,0)

func _ready():
	#var siema = Vector2i(1,1)
	#var table : Array[Array] = [[0,0],[1,1]]
	#print(table.any(table.has)
	randomize()
	#generate_connection_graph(ROOM_NUMBER)
	#connection_graph.print_graph()
	#connection_graph.bfs()
	#connection_graph.djikstra()
	#draw_room(generate_room())
	#test_generate_dungeon()
	generate_dungeon()

func _physics_process(delta):
	pass

func test_generate_dungeon():
	for i in range(1000):
		tile_map.clear()
		generate_dungeon()
		print(tile_map.get_used_rect())

func _input(event):
	if event.is_action_pressed("ui_left"):
		debug_position += Vector2i.LEFT
	if event.is_action_pressed("ui_right"):
		debug_position += Vector2i.RIGHT
	if event.is_action_pressed("ui_up"):
		debug_position += Vector2i.UP
	if event.is_action_pressed("ui_down"):
		debug_position += Vector2i.DOWN
	
	if event.is_action_pressed("ui_accept"):
		tile_map.set_cell(debug_position,0 ,floor_tile)


###### DUNGEON PART
func generate_dungeon():
	for i in ROOM_NUMBER:
		room_table.append(generate_room())
	
	var current_point = Vector2i(0,0)
	var room = room_table[0]
	draw_room(room, current_point)
	#for new_room in room_table.slice(1):
		#var point_table = place_room(room, new_room, current_point)
		#current_point = point_table["new_point"]
		#draw_room(new_room, current_point)
		#draw_connection(point_table["pin"], current_point)
		#room = new_room
	var placed_rooms = [room]
	var used_points = [current_point]
	room_table.erase(room)
	while !room_table.is_empty():
		var new_room = room_table.front()
		room_table.pop_front()
		var point_table = place_room(room, new_room, current_point)
		if point_table==null:
			room_table.append(new_room)
			room = placed_rooms.pick_random()
			current_point = used_points[placed_rooms.find(room)]
			continue
		current_point = point_table["new_point"]
		draw_room(new_room, current_point)
		draw_connection(point_table["pin"], current_point)
		placed_rooms.append(new_room)
		used_points.append(current_point)
		room = placed_rooms.pick_random()
		current_point = used_points[placed_rooms.find(room)]
		

func draw_room(room:Array, starting_point:Vector2i):
	var offset_x = room[0].size()/2
	var offset_y = room.size()/2
	for y in range(room.size()):
		for x in range(room[y].size()):
			var tile_position = Vector2i(starting_point.x + x-offset_x, starting_point.y + y-offset_y)
			if room[y][x] == 0:
				tile_map.set_cell(tile_position,0,floor_tile)
			#else:
				#tile_map.set_cell(tile_position, 0, wall_tile)
	
func place_room(current_room: Array, new_room:Array, current_point:Vector2i):
	var new_point:Vector2i
	var pin:Vector2i
	var counter:int = 0
	while !is_point_viable(new_room, new_point):
		if counter == 6:
			return null
		counter+=1
		while true:
			pin = Vector2i(randi_range(0, current_room[0].size()-1), randi_range(0, current_room.size()-1))
			if current_room[pin.y][pin.x] == 0:
				break
		var random_number = randi()%4
		random_number = 2
		#pin = Vector2i(current_room[0].size()/2,current_room.size()/2)
		#pin -= Vector2i(current_room[0].size()/2,current_room.size()/2) #center pin
		match random_number:
			0: #UP
				pin = move_pin_to_side(pin,current_room,Vector2i.DOWN)
				new_point = current_point + Vector2i(pin.x, -(current_room.size()/2+new_room.size()/2 + STANDARD_GAP))
			1: #DOWN
				pin = move_pin_to_side(pin,current_room,Vector2i.UP)
				new_point = current_point + Vector2i(pin.x, current_room.size()/2+new_room.size()/2 + STANDARD_GAP)
			2: #LEFT
				print(pin)
				pin = move_pin_to_side(pin,current_room,Vector2i.LEFT)
				new_point = current_point + Vector2i(-(current_room[0].size()/2 + new_room[0].size()/2 + STANDARD_GAP), pin.y)
			3: #RIGHT
				pin = move_pin_to_side(pin,current_room,Vector2i.RIGHT)
				new_point = current_point + Vector2i(current_room[0].size()/2+new_room[0].size()/2 + STANDARD_GAP, pin.y)
	return {"new_point": new_point,"pin": pin+current_point}

func move_pin_to_side(pin:Vector2i, room:Array, direction:Vector2i):
	var final_pin:Vector2i = pin
	while (pin.x in range(1,room[0].size()-1)) and (pin.y in range(1,room.size()-1)):
		pin+= direction
		if room[pin.y][pin.x] == 0:
			final_pin = pin
	print(final_pin)
	final_pin -= Vector2i(room[0].size()/2,room.size()/2)
	return final_pin
		
func is_point_viable(room:Array, point:Vector2i):
	var offset_x = room[0].size()/2
	var offset_y = room.size()/2
	for y in range(room.size()+1):
		for x in range(room[y-1].size()+1):
			var tile_position = Vector2i(point.x + x-offset_x, point.y + y-offset_y)
			if tile_map.get_cell_tile_data(tile_position) != null:
				return false
	return true
	
func draw_connection(point1:Vector2i, point2:Vector2i):
	var point_step: Vector2i = (point2 - point1)/(point2 - point1).length()
	var tile_position = point1
	while tile_position != point2:
		tile_position += point_step
		tile_map.set_cell(tile_position,0,floor_tile)
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
		
	if room.is_empty():
		for y in range(MAX_ROOM_SIZE/2):
			room.append([])
			for x in range(MAX_ROOM_SIZE/2):
					room[y].append(0)
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
####### GRAPH PART
func generate_connection_graph(room_count:int):
	connection_graph = Graph.new(room_count)
