extends CharacterBody2D

class_name player_character
signal pressedEnter
@export var turn_queue:turn_queue
var turn_mode = false
var move_mode = false
@onready var timer = $Timer

const SPEED = 50.0

func _ready():
	turn_queue=%turn_queue
	
func _physics_process(delta):
	if Input.is_action_pressed("ui_focus_next"):
			turn_queue.turn_mode_start.emit()
	if turn_mode and turn_queue.active_char == $"." and move_mode:
		if Input.is_action_pressed("ui_left"):
			position+=Vector2(SPEED*-1, 0)
			#end_turn()
		elif Input.is_action_pressed("ui_right"):
			position+=Vector2(SPEED*1, 0)
			#end_turn()
		elif Input.is_action_pressed("ui_up"):
			position+=Vector2(0, SPEED*-1)
			#end_turn()
		elif Input.is_action_pressed("ui_down"):
			position+=Vector2(0, SPEED)
			#end_turn()
	elif turn_mode == false:
		if Input.is_action_pressed("ui_left"):
			position+=Vector2(SPEED*-1, 0)
		elif Input.is_action_pressed("ui_right"):
			position+=Vector2(SPEED*1, 0)
		elif Input.is_action_pressed("ui_up"):
			position+=Vector2(0, SPEED*-1)
		elif Input.is_action_pressed("ui_down"):
			position+=Vector2(0, SPEED)

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
