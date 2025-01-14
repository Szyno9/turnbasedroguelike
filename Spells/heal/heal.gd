extends Node2D

var target:Vector2
var protected_group: String
var damage = -25
# Called when the node enters the scene tree for the first time.
func _ready():
	if target == null:
		queue_free()
	global_position = target

func _physics_process(_delta):
	await get_tree().create_timer(1).timeout
	queue_free()
	#process_mode = Node.PROCESS_MODE_DISABLED

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
			body.take_damage(damage)
