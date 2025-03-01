extends Node2D

var target:Vector2
var protected_group: String
const speed = 180
var damage = 5
var explosion_scene:PackedScene = preload("res://Spells/fireball/fireball_explosion/fireball_explosion.tscn")
var explosion_radius = 2
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
		explode(target)
	position += direction * speed * delta
	rotation = direction.angle()

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage") and not body.is_in_group(protected_group):
		body.take_damage(damage)
		call_deferred("explode",body.global_position)#explode()

func explode(explosion_center:Vector2):
	const DIRECTIONS = [Vector2.LEFT*16, Vector2.RIGHT*16, Vector2.UP*16, Vector2.DOWN*16]
	#for i in range(-explosion_radius,explosion_radius+1):
		#for j in range(-explosion_radius,explosion_radius+1):
			#var single_explosion:Node2D = explosion_scene.instantiate()
			#single_explosion.global_position = explosion_center + Vector2(i*16,j*16)
			#single_explosion.damage = roundi(damage/2)
			#add_sibling(single_explosion)
	#queue_free()
	
	var cell_stack: Array = [explosion_center]
	var current_overlay:Array
	while not cell_stack.is_empty():
		var current = cell_stack.pop_back()
		if current in current_overlay:
			continue
		if explosion_center.distance_to(current) > explosion_radius*16:
			continue
		current_overlay.append(current)
		
		for direction in DIRECTIONS:
			var cell: Vector2 = current + direction
			if cell in current_overlay:
				continue
			cell_stack.append(cell)
	for cell in current_overlay:
		var single_explosion:Node2D = explosion_scene.instantiate()
		single_explosion.global_position = cell
		single_explosion.damage = roundi(damage/2)
		add_sibling(single_explosion)
	queue_free()
