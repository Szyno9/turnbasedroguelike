extends EnemyBase

const SPEED = 50.0

func _ready():
	super()
	spell_book.add_spell(load("res://Spells/missle/missle.tres"))
	TurnQueueGlobal.global_tick.connect("timeout", Callable(self, "patrol"))
	#astar_grid = AStarGrid2D.new()
	#astar_grid.region = tile_map.get_used_rect()
	#astar_grid.cell_size = Vector2(32, 32)
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.update()

func _process(_delta):
	pass
func _physics_process(delta):
	super(delta)
	move_path()
	if TurnQueueGlobal.turn_mode and TurnQueueGlobal.active_char == self:
		if not is_moving and not ai_processing:
			turn_ai()
		
	
