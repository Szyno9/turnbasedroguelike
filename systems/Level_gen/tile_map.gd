extends TileMap

class_name LevelMap
var astar_grid: AStarGrid2D = AStarGrid2D.new()

func _input(event):
	if event.is_action_pressed("debug"):
		next_level()

func new_level():
	GlobalDataBus.elements.clear()
	$LevelGenerator.new_level()

func next_level():
	GlobalDataBus.elements.clear()
	$LevelGenerator.new_level()

func initialize():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	set_solid()
	GlobalDataBus.level_changed.emit()

func _physics_process(_delta):
	pass

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
	for character in get_parent().get_children():
		if character.is_class("CharacterBody2D"):
			char_position.append(local_to_map(character.global_position))

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
