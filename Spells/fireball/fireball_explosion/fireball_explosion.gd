extends Node2D

var target:Vector2
var damage = 5
# Called when the node enters the scene tree for the first time.


func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _on_animated_sprite_2d_animation_finished():
	queue_free()
