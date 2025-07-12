extends Node2D

var target:Vector2
var protected_group: String
var damage = 5
var range = 24

# Called when the node enters the scene tree for the first time.
func _ready():
	global_transform.x = Vector2(1,0)
	var displacement := target-global_position
	var direction := displacement.normalized()*16
	global_position+=direction
	%Area2D.global_position+=direction
	%AnimatedSprite2D.rotation = direction.angle()
	$Start/AnimatedSprite2D.rotation =direction.angle()
	explode(direction)
	

	

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage") and not body.is_in_group(protected_group):
		body.take_damage(damage)

func explode(direction):
	for i in range(1, range):
		var new_segment = %Area2D.duplicate()
		new_segment.position+=direction*i
		add_child(new_segment)


func _on_animated_sprite_2d_animation_finished():
	queue_free()
