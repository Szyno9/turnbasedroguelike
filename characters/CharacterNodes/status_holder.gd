extends Node

class_name StatusHolder
# Called when the node enters the scene tree for the first time.
func _ready():
	TurnQueue.global_tick.connect("timeout", Callable(self, "turn_tick_status_check"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func damage_status_check(damage:int):
	for status in get_children():
		for status_type in status.type:
			match status_type:
				GlobalEnums.STATUS_TYPE.SHIELD:
					status.health-=1
					damage = 0
				GlobalEnums.STATUS_TYPE.VULNERABLE:
					damage *= status.multiplier
	return damage
	
func turn_tick_status_check():
	for status in get_children():
		status.duration -= 1
