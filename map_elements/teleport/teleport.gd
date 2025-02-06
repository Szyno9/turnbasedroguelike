extends Node2D

var destination = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass	

func _on_area_2d_body_entered(body):
	if body.has_method("teleport_to_location"):
		body.teleport_to_location(destination)
