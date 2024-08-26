extends CharacterBody2D

class_name player_character
signal pressedEnter
var turn_queue:turn_queue

const SPEED = 50.0

func _ready():
	turn_queue = get_parent()
	print("gittest")

func _physics_process(delta):
	
	if Input.is_action_pressed("ui_accept"):
		pressedEnter.emit()
	

func play_turn():
	print("tu jestem")
	await pressedEnter
	position+=Vector2(SPEED,SPEED)
	await get_tree().create_timer(0.5).timeout
	end_turn()
	
func end_turn():
	turn_queue.play_turn()
