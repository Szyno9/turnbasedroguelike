extends Node2D

# Konfiguracja rozmiaru kafelka i mapy
const TILE_SIZE = 32
const SIZE = Vector2i(100, 100) # Wymiary mapy

# Mapa terenu
var terrain_map = []

@onready var tile_map = $TileMapLayer
 
var floor_tile := Vector2i(0,0)
var wall_tile := Vector2i(1,0)

# Wywołanie generowania jaskini
func _ready():
	CaveGeneration(TILE_SIZE, SIZE, terrain_map)
	draw_dungeon()

# Funkcja główna generowania jaskini
func CaveGeneration(tile_size, size, terrain_map):
	# Inicjalizacja losowa mapy
	initialize_map(size)
	
	# Aktualizacja każdego kafla w mapie terenu
	for y in range(size.y):
		for x in range(size.x):
			update_tile_with_l_system(x, y)
			update_tile_with_cellular_automata(x, y)
	
	smooth_map()


# Funkcja inicjalizująca mapę losowo
func initialize_map(size):
	for y in range(size.y):
		var row = []
		for x in range(size.x):
			if (randf() < 0.45):  # Losowa inicjalizacja: 1 - ściana, 0 - wolna przestrzeń
				row.append(0)
			else:
				row.append(1)
		terrain_map.append(row)

# Funkcja aktualizacji kafla przy użyciu prostego L-systemu
func update_tile_with_l_system(x, y):
	# Przykładowy prosty algorytm L-system: ustawia ściany w zależności od sąsiedztwa
	if terrain_map[y][x] == 1:  # Jeśli aktualny kafel to ściana
		var neighbors = get_wall_count(x, y)
		if neighbors < 3:
			terrain_map[y][x] = 0  # Zamienia na otwartą przestrzeń

# Funkcja automatu komórkowego do wygładzania
func update_tile_with_cellular_automata(x, y):
	var neighbors = get_wall_count(x, y)
	if terrain_map[y][x] == 0:  # Jeśli to wolna przestrzeń
		if neighbors > 4:
			terrain_map[y][x] = 1  # Zmienia na ścianę
	else:
		if neighbors < 4:
			terrain_map[y][x] = 0  # Zmienia na wolną przestrzeń

# Funkcja licząca sąsiednie ściany
func get_wall_count(x, y):
	var count = 0
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var nx = x + dx
			var ny = y + dy
			if nx >= 0 and ny >= 0 and nx < SIZE.x and ny < SIZE.y:
				count += terrain_map[ny][nx]
			else:
				count += 1  # Uważamy granicę mapy za ścianę
	return count

# Funkcja końcowego wygładzania
func smooth_map():
	for y in range(SIZE.y):
		for x in range(SIZE.x):
			var neighbors = get_wall_count(x, y)
			if neighbors > 4:
				terrain_map[y][x] = 1
			elif neighbors < 4:
				terrain_map[y][x] = 0

func draw_dungeon():
	# Loop through each cell in the grid
	for x in range(SIZE.x):
		for y in range(SIZE.y):
			var tile_position = Vector2i(x, y)
			if terrain_map[x][y] == 0:
				tile_map.set_cell(tile_position,0,floor_tile)
			else:
				tile_map.set_cell(tile_position, 0, wall_tile)
