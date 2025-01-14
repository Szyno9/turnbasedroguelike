extends Node2D

var target:Vector2
var protected_group: String
var damage = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	if target == null:
		queue_free()
	position = target


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass
	#var displacement := target - global_transform.origin
	#var direction := displacement.normalized()
	

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage") and not body.is_in_group(protected_group):
		body.take_damage(damage)


func _on_animated_sprite_2d_animation_finished():
	queue_free()
