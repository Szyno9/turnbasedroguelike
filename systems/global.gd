extends Node

var astar_grid: AStarGrid2D = AStarGrid2D.new()
var tile_map: TileMapLayer

func _ready():
	tile_map=$TileMapLayer
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
