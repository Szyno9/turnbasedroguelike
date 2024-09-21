extends EnemyBase
@onready var timer = $Timer

const SPEED = 50.0

func _ready():
	super()
	spell_book.add_spell(load("res://Spells/missle/missle.tres"))
	TurnQueue.global_tick.connect("timeout", Callable(self, "patrol"))
	#astar_grid = AStarGrid2D.new()
	#astar_grid.region = tile_map.get_used_rect()
	#astar_grid.cell_size = Vector2(32, 32)
	#astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	#astar_grid.update()

func _process(delta):
	pass
func _physics_process(delta):
	move_path()
	if TurnQueue.turn_mode and TurnQueue.active_char == self:
		simple_decision()
		
	
