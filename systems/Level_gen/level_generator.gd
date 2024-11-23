extends Node2D
@onready var tile_map = $TileMapLayer
 
var floor_tile := Vector2i(0,0)
var wall_tile := Vector2i(1,0)
 
# Constants defining the grid size, cell size, and room parameters
const WIDTH = 120
const HEIGHT = 80
const MIN_ROOM_SIZE = 7
const MAX_ROOM_SIZE = 10
const MAX_ROOMS = 10
 
# Arrays to hold the grid data and the list of rooms
var grid = []
var rooms = []
 
# _ready is called when the node is added to the scene
func _ready():
	# Initialize the random number generator
	randomize()
	# Create the grid filled with walls
	initialize_grid()
	# Generate the dungeon by placing rooms and connecting them
	generate_dungeon()
	# Draw the dungeon on the screen
	draw_dungeon()
 
# Initializes the grid with all cells set to walls (represented by 1)
func initialize_grid():
	for x in range(WIDTH):
		grid.append([])  # Add a new row to the grid
		for y in range(HEIGHT):
			grid[x].append(1)  # Fill each cell in the row with 1 (wall)
 
# Main function to generate the dungeon by placing rooms and connecting them
func generate_dungeon():
	for i in range(MAX_ROOMS):
		# Generate a room with random size and position
		var room = generate_room()
		# Attempt to place the room in the grid
		if place_room(room):
			# If this isn't the first room, connect it to the previous room
			if rooms.size() > 0:
				connect_rooms(rooms[-1], room)  # Connect the new room to the last placed room
			# Add the room to the list of rooms in the dungeon
			rooms.append(room)
 
# Generates a room with random width, height, and position within the grid
func generate_room():
	# Determine room width and height randomly within the specified range
	var room = []
	for y in range(MAX_ROOM_SIZE):
		room.append([])
		for x in range(MAX_ROOM_SIZE):
			if (randf() < 0.5):  # Losowa inicjalizacja: 1 - ściana, 0 - wolna przestrzeń
				room[y].append(0)
			else:
				room[y].append(1)
	room = smooth_room(room)
	return room

func smooth_room(room: Array):
	for y in range(MAX_ROOM_SIZE):
		for x in range(MAX_ROOM_SIZE):
			var neighbors = get_wall_count(room, x, y)
			print(neighbors)
			if neighbors > 4:
				room[y][x] = 1
			elif neighbors < 4:
				room[y][x] = 0
	return room
	
func get_wall_count(room: Array, x: int, y: int):
	var count = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and ny >= 0 and nx < MAX_ROOM_SIZE and ny < MAX_ROOM_SIZE:
				count += room[ny][nx]
			else:
				count += 1  # Uważamy granicę mapy za ścianę
	return count
	
# Attempts to place the room on the grid, ensuring no overlap with existing rooms
func place_room(room):
	# Check if the room overlaps with any existing floors (cells set to 0)
	for x in range(MAX_ROOM_SIZE):
		for y in range(MAX_ROOM_SIZE):
			if grid[x][y] == 0 and room[x][y] == 0:  # If the cell is already a floor
				return false  # Room cannot be placed, return false
	
	# If no overlap is found, mark the room area as floors (set cells to 0)
	for x in range(MAX_ROOM_SIZE):
		for y in range(MAX_ROOM_SIZE):
			if room[x][y] == 0:
				grid[x][y] = 0  # 0 represents a floor
	return true  # Room successfully placed, return true
 
# Connects two rooms with a corridor, allowing for a customizable corridor width
func connect_rooms(room1, room2, corridor_width=1):
	return
	# Determine the starting point for the corridor (center of room1)
	var start = Vector2(
		int(room1.position.x + room1.size.x / 2),
		int(room1.position.y + room1.size.y / 2)
	)
	# Determine the ending point for the corridor (center of room2)
	var end = Vector2(
		int(room2.position.x + room2.size.x / 2),
		int(room2.position.y + room2.size.y / 2)
	)
	
	var current = start
	
	# First, move horizontally towards the end point
	while current.x != end.x:
		# Move one step left or right
		current.x += 1 if end.x > current.x else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.y + j >= 0 and current.y + j < HEIGHT and current.x + i >= 0 and current.x + i < WIDTH:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
 
	# Then, move vertically towards the end point
	while current.y != end.y:
		# Move one step up or down
		current.y += 1 if end.y > current.y else -1
		# Create a corridor with the specified width
		for i in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
			for j in range(-int(corridor_width / 2), int(corridor_width / 2) + 1):
				# Ensure we don't go out of grid bounds
				if current.x + i >= 0 and current.x + i < WIDTH and current.y + j >= 0 and current.y + j < HEIGHT:
					grid[current.x + i][current.y + j] = 0  # Set cells to floor
 
# Draws the dungeon on the screen by creating visual representations of the grid
func draw_dungeon():
	# Loop through each cell in the grid
	for x in range(WIDTH):
		for y in range(HEIGHT):
			var tile_position = Vector2i(x, y)
			if grid[x][y] == 0:
				tile_map.set_cell(tile_position,0,floor_tile)
			else:
				tile_map.set_cell(tile_position, 0, wall_tile)
