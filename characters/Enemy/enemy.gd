extends CharacterBody2D

class_name hostile_character
var turn_queue:turn_queue
@export var turn_mode=false
@onready var DetectionArea = $DetectionArea

const SPEED = 50.0

func _ready():
	if get_parent().get_class() == "turn_queue":
		turn_queue=get_parent()

func _physics_process(delta):
	if turn_mode == false:
		var random = randi()%4
		if random == 0:
			position+=+Vector2(SPEED*-1,0)
		elif random == 1:
			position+=+Vector2(SPEED,0)
		elif random == 2:
			position+=+Vector2(0,SPEED*-1)
		elif random == 3:
			position+=+Vector2(0,SPEED)
	
func play_turn():
	var random = randi()%4
	if random == 0:
		position+=+Vector2(SPEED*-1,0)
	elif random == 1:
		position+=+Vector2(SPEED,0)
	elif random == 2:
		position+=+Vector2(0,SPEED*-1)
	elif random == 3:
		position+=+Vector2(0,SPEED)
	move_and_slide()
	end_turn()

func end_turn():
	turn_queue.play_turn()
	
func turn_modeON():
	if turn_mode==false:
		turn_mode=true
		for entity in DetectionArea.get_overlapping_bodies():
			print(entity)
			entity.call_deferred("turn_modeON")
		var new_parent = get_node("/root/main/turn_queue")
		get_parent().remove_child(self)
		new_parent.add_child(self)
		
