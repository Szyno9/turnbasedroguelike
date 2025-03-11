extends Node2D

var target:Vector2
var protected_group: String
const spell_range = 25
const speed = 250
var damage = 1

var displacement
var direction
var distance
var distance_traveled = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	if target == null:
		queue_free()
	displacement = target - global_transform.origin
	direction = displacement.normalized()
	distance = displacement.length()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if distance_traveled >= spell_range*speed:
		queue_free()
	position += direction * speed * delta
	rotation = direction.angle()
	distance_traveled += speed/3

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage") and not body.is_in_group(protected_group):
		body.take_damage(damage)
