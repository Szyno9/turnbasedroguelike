extends Node2D

var target:Vector2
var protected_group: String
const spell_range = 0
const speed = 0
var damage = 0

var type = [GlobalEnums.STATUS_TYPE.SHIELD]
var health = 1
var duration = 3

func _physics_process(_delta):
	if health <= 0 or duration <= 0:
		queue_free()


func _on_area_2d_body_entered(body):
	$Area2D/CollisionShape2D.set_deferred("disabled", true)   
	var status_holder = body.status_holder
	get_parent().call_deferred("remove_child",self)
	status_holder.call_deferred("add_child",self)
	position=Vector2(0,0)
