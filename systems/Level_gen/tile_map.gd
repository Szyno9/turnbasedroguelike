extends TileMap

class_name LevelMap
var astar_grid: AStarGrid2D = AStarGrid2D.new()

var tilemaps_group: ResourceGroup = load("res://assets/TileSetMaps/level_tilemaps.tres")

var level_tilesets:Array = tilemaps_group.load_all()

var spawn_point: Vector2i

func _ready():
	GlobalDataBus.start_game.connect(start_level)
	GlobalDataBus.move_to_next_level.connect(new_level)
	GlobalDataBus.scene_changed_from_main.connect(reset)

var physics_counter = 0
func _physics_process(delta):
	physics_counter+=1
	if physics_counter%30 == 0:
		test()

func _input(event):
	if event.is_action_pressed("debug"):
		new_level()

func start_level():
	print("elo")
	tile_set = level_tilesets[GlobalDataBus.current_level]
	$LevelGenerator.new_level()
	GlobalDataBus.level_changed.emit()
	GlobalDataBus.set_spawn_point.emit(spawn_point)


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

func reset():
	clear()
