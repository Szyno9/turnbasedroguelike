extends CharacterBody2D

class_name player_character
signal pressedEnter
@export var turn_queue:turn_queue
var turn_mode = false
var move_mode = false
@onready var timer = $Timer

var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
@onready var tile_map = $"../TileMapLayer"

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(32, 32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	turn_queue=%turn_queue
	
func _input(event):
	if event.is_action_pressed("move") == false:
		return
	
	var id_path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map((get_global_mouse_position()))
	).slice(1)
	
	if id_path.is_empty() == false:
		current_id_path = id_path
	
func _physics_process(delta):
	if Input.is_action_pressed("ui_focus_next"):
			turn_queue.turn_mode_start.emit()
	
	if current_id_path.is_empty():
		return
		
	var target_position = tile_map.map_to_local(current_id_path.front())

	global_position = global_position.move_toward(target_position, 3)

	if global_position == target_position:
		current_id_path.pop_front()
	

func play_turn():
	pass
	
func end_turn():
	turn_queue.play_turn()

func turn_modeON():
	if turn_mode == false:
		turn_mode=true
		var new_parent = get_node(turn_queue.get_path())
		get_parent().remove_child(self)
		new_parent.add_child(self)

func _on_area_2d_body_entered(body):
	if(turn_mode==false):
		call_deferred("turn_modeON")
		body.call_deferred("turn_modeON");


func _on_timer_timeout(): #obsolete for player
	turn_queue.play_turn()


func _on_end_turn_button_pressed():
	turn_queue.play_turn()


func _on_move_button_pressed():
	if move_mode == false:
		move_mode = true
	else:
		move_mode = false
