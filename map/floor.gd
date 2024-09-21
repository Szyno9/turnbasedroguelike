extends TileMapLayer

class_name Floor

var astar_grid: AStarGrid2D = AStarGrid2D.new()
var tile_map: TileMapLayer

func _ready():
	tile_map=self
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

func _physics_process(delta):
	test()

func test():
	var chars:Array
	for character in get_parent().get_children():
		if character.is_class("CharacterBody2D"):
			chars.append(character)
	for tile in get_used_cells():
		for character in chars:
			if tile_map.local_to_map(character.global_position) == tile:
				astar_grid.set_point_solid(tile, true)
			else:
				astar_grid.set_point_solid(tile, false)
	
