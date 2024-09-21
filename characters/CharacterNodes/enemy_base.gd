extends CharacterBase

class_name EnemyBase

var next_tile:Vector2i
#var is_moving:bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	super()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func patrol(): #TODO PRZEROBIĆ
	if is_moving == false and TurnQueue.turn_mode == false:
		set_id_path(get_random_surrouding_tile())#next_tile = get_random_surrouding_tile()
		is_moving = true

func simple_decision():
	if actions <=0 and speed > 0 and is_moving == false:
		set_id_path(get_random_surrouding_tile()) #set_id_path(Vector2i(0,0))
	elif actions <= 0 and speed == 0:
		end_turn()
	if actions > 0:
		next_attack = choose_spell()
		var target = find_target()
		if target != null:
			cast_spell(target,"hostile", next_attack)
	
func choose_spell(): #TODO do przerobienia, mmoże się przyda
	var spell = spell_book.pick_random()
	return spell
	
