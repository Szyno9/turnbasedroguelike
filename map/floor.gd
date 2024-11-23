extends TileMapLayer

class_name Floor

var astar_grid: AStarGrid2D = AStarGrid2D.new()
var tile_map: TileMapLayer

func _ready():
	tile_map=self
	astar_grid = AStarGrid2D.new()
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

func _physics_process(delta):
	if Engine.get_physics_frames() % 30 == 0:
		test()

func test():
	var char_position:Array[Vector2i]
	for character in get_parent().get_children():
		if character.is_class("CharacterBody2D"):
			char_position.append(local_to_map(character.global_position))
	#for tile in get_used_cells():
		#for character in chars:
			#if tile_map.local_to_map(character.global_position) == tile:
				#astar_grid.set_point_solid(tile, true)
			#else:
				#astar_grid.set_point_solid(tile, false)
	
	for x in get_used_rect().size.x:
			for y in get_used_rect().size.y:
				var tile_position = Vector2i(
					x+get_used_rect().position.x,
					y+get_used_rect().position.y
				)
				if tile_position in char_position:
					astar_grid.set_point_solid(tile_position, true)
				else:
					astar_grid.set_point_solid(tile_position, false)
						
				#for character in chars:
					#if tile_map.local_to_map(character.global_position) == tile_position:
						#print("it works")
						#astar_grid.set_point_solid(tile_position, true)
						#set_cell(tile_position,-1,Vector2i(-1,-1),1)
					#else:
						#astar_grid.set_point_solid(tile_position, false)
