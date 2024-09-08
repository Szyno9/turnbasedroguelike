extends State
class_name Patrol

@export var enemy: CharacterBody2D

var move_destination : Vector2

func patrol_around():
	var move_destination = enemy.tile_map.map_to_local(
		enemy.tile_map.local_to_map(enemy.global_position),
		enemy.tile_map.local_to_map(enemy.global_position)-enemy.tile_map.local_to_map(Vector2(randi_range(-1,1), randi_range(-1,1)))
		).slice(1)
	#move_destination = enemy.global_position+move_direction
# Called when the node enters the scene tree for the first time.
func Enter():
	patrol_around()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func Update(delta):
	if enemy.global_position == move_destination:
		print("jestem")
	else:
		print("jeszcze nie")
		#patrol_around()
	
func Physics_Update(_delta: float):
	if enemy:
		enemy.global_position = enemy.global_position.move_toward(move_destination, 5)

func _on_timer_timeout() -> void:
	pass
