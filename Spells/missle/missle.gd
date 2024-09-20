extends Node2D

var target:Vector2
var protected_group: String
const speed = 500
var damage = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	if target == null:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var displacement := target - global_transform.origin
	var direction := displacement.normalized()
	var distance := displacement.length()
	if distance <= 5:
		queue_free()
	position += direction * speed * delta


func _on_area_2d_body_entered(body):
	if body.has_method("take_damage") and not body.is_in_group(protected_group):
		body.take_damage(damage)
		queue_free()
