extends CharacterBody2D

class_name player_character
signal pressedEnter
var turn_queue:turn_queue

const SPEED = 50.0

func _ready():
	turn_queue = get_parent()

func _physics_process(delta):
	
	if turn_queue.combat_mode == true:
		if Input.is_action_pressed("ui_accept"):
			pressedEnter.emit()
	else:
		if Input.is_action_pressed("ui_left"):
			position+=Vector2(SPEED*-1, 0)
		elif Input.is_action_pressed("ui_right"):
			position+=Vector2(SPEED*1, 0)
		elif Input.is_action_pressed("ui_up"):
			position+=Vector2(0, SPEED*-1)
		elif Input.is_action_pressed("ui_down"):
			position+=Vector2(0, SPEED)

func play_turn():
	print("tu jestem")
	await pressedEnter
	position+=Vector2(SPEED,SPEED)
	await get_tree().create_timer(0.5).timeout
	end_turn()
	
func end_turn():
	turn_queue.play_turn()
