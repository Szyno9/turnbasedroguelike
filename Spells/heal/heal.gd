extends Node2D

var target:Vector2
var protected_group: String
var damage = -25
# Called when the node enters the scene tree for the first time.
func _ready():
	if target == null:
		queue_free()
	global_position = target

func _physics_process(delta):
	for char in $Area2D.get_overlapping_bodies():
		if char.has_method("take_damage"):
			char.take_damage(damage)
	await get_tree().create_timer(0.005).timeout
	queue_free()
	#process_mode = Node.PROCESS_MODE_DISABLED
	
func heal_characters():
	for char in $Area2D.get_overlapping_bodies():
		if char.has_method("take_damage"):
			char.take_damage(damage)
	await get_tree().create_timer(2).timeout
	queue_free()
	
