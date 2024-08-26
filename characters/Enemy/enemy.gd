extends CharacterBody2D

class_name hostile_character
var turn_queue:turn_queue

const SPEED = 50.0

func _ready():
	turn_queue=get_parent()

func _physics_process(delta):
	pass
	
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
	print(self.name)
	end_turn()

func end_turn():
	turn_queue.play_turn()


func _on_detection_shape_body_entered(body):
	print("dziendobry")
	turn_queue.combat_mode=true
