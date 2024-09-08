extends CharacterBody2D

class_name hostile_character
var turn_queue:turn_queue
@export var turn_mode=false
@onready var DetectionArea = $DetectionArea
@onready var timer = $Timer

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
@export var is_moving = false
var surround_table:Array[Vector2i]
@onready var tile_map = $"../TileMapLayer"

signal move_finished

var direction: Vector2i

const SPEED = 50.0

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	turn_queue = %turn_queue

func _process(delta):
	pass
func _physics_process(delta):
	if turn_mode == false:
		patrol()
	elif turn_mode and is_moving:
		move_to_tile(direction)
	
	
func play_turn():
	direction = get_random_surrouding_tile()
	is_moving = true
	move_and_slide()
	
func turn_modeON():
	if turn_mode==false:
		turn_mode=true
		for entity in DetectionArea.get_overlapping_bodies():
			entity.call_deferred("turn_modeON")
		var new_parent = get_node("/root/main/turn_queue")
		get_parent().remove_child(self)
		new_parent.add_child(self)
		
func patrol():
	if is_moving == false:
		direction = get_random_surrouding_tile()
		is_moving = true
	elif is_moving:	
		move_to_tile(direction)
		
func get_random_surrouding_tile():
	surround_table = tile_map.get_surrounding_cells(tile_map.local_to_map(global_position))
	return surround_table[randi_range(0,3)]

func move_to_tile(direction):
	global_position = global_position.move_toward(tile_map.map_to_local((direction)), 1)
	if tile_map.map_to_local(direction) == global_position:

		is_moving = false
		emit_signal("move_finished")

func _on_timer_timeout():
	turn_queue.play_turn()


func _on_move_finished():	
	if turn_mode:
		turn_queue.play_turn()
	else:
		pass
