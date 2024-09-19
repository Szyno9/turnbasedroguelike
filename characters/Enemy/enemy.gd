extends CharacterBase
@onready var timer = $Timer

var surround_table:Array[Vector2i]
var direction: Vector2i
const SPEED = 50.0

func _ready():
	super()
	
	#astar_grid = AStarGrid2D.new()
	#astar_grid.region = tile_map.get_used_rect()
	#astar_grid.cell_size = Vector2(32, 32)
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.update()

func _process(delta):
	pass
func _physics_process(delta):
	if turn_mode == false:
		patrol()
	elif turn_mode and is_moving:
		move_one_tile(direction)
		if speed == 0:
			TurnQueue.play_turn()
	
	
func play_turn():
	direction = get_random_surrouding_tile()
	is_moving = true
	move_and_slide()
		
func patrol():
	if is_moving == false:
		direction = get_random_surrouding_tile()
		is_moving = true
	elif is_moving:	
		move_one_tile(direction)
		
func get_random_surrouding_tile():
	surround_table = tile_map.get_surrounding_cells(tile_map.local_to_map(global_position))
	return surround_table[randi_range(0,3)]



func _on_move_finished():
	pass	
	if turn_mode:
		TurnQueue.play_turn()
	else:
		pass
