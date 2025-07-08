extends TileMap

class_name LevelMap
var astar_grid: AStarGrid2D = AStarGrid2D.new()

var level_0_tileset:TileSet = load("res://assets/tilesets/level_map_1.tres")
var level_1_tileset:TileSet = load("res://assets/tilesets/level_map_2.tres")

var level_tilesets:Array[TileSet] = [level_0_tileset,level_1_tileset]

var spawn_point: Vector2i

func _ready():
	GlobalDataBus.connect("move_to_next_level", new_level)

var physics_counter = 0
func _physics_process(delta):
	physics_counter+=1
	if physics_counter%30 == 0:
		test()

func _input(event):
	if event.is_action_pressed("debug"):
		new_level()

func new_level():
	GlobalDataBus.current_level=(GlobalDataBus.current_level+1) % level_tilesets.size()
	GlobalDataBus.elements.clear()
	tile_set = level_tilesets[GlobalDataBus.current_level]
	$LevelGenerator.new_level()
	GlobalDataBus.level_changed.emit()
	GlobalDataBus.set_spawn_point.emit(spawn_point)


func initialize():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	set_solid()


func set_solid():
	for x in get_used_rect().size.x:
			for y in get_used_rect().size.y:
				var tile_position = Vector2i(
					x+get_used_rect().position.x,
					y+get_used_rect().position.y
				)
				var tile_data = get_cell_tile_data(0,tile_position)
				if tile_data.get_custom_data("is_solid") == true:
					astar_grid.set_point_solid(tile_position)

func test():
	var char_position:Array[Vector2i]
	for element in GlobalDataBus.elements:
		if element != null:
			char_position.append(local_to_map(element.global_position))

	for x in get_used_rect().size.x:
			for y in get_used_rect().size.y:
				var tile_position = Vector2i(
					x+get_used_rect().position.x,
					y+get_used_rect().position.y
				)
				var tile_data = get_cell_tile_data(0,tile_position)
				if tile_position in char_position:
					astar_grid.set_point_solid(tile_position, true)
				elif tile_data.get_custom_data("is_solid") == false:
					astar_grid.set_point_solid(tile_position, false)
