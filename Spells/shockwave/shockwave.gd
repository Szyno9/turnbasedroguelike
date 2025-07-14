extends Node2D

var target:Vector2
var protected_group: String
const spell_range = 5
const speed = 250
var damage = 1
var direction = Vector2(0,0)
var max_cone_size = 72
# Called when the node enters the scene tree for the first time.
func _ready():
	if target == null:
		queue_free()
	var displacement := target - global_transform.origin
	direction = displacement.normalized()
	global_position += direction * 16
	rotation = direction.angle()
	
	

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage") and not body.is_in_group(protected_group):
		body.take_damage(damage)


func _on_animated_sprite_2d_animation_finished():
	queue_free()


func _on_animated_sprite_2d_frame_changed():
	global_position += direction * 16
	if %CollisionShape2D.shape.size.y == 0:
		%CollisionShape2D.shape.size.y = 8
	elif max_cone_size > %CollisionShape2D.shape.size.y:
		%CollisionShape2D.shape.size.y +=32
