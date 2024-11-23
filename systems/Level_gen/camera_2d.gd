extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event.is_action_pressed("ui_left"):
		offset.x-=100
	if event.is_action_pressed("ui_right"):
		offset.x+=100
	if event.is_action_pressed("ui_up"):
		offset.y-=111
	if event.is_action_pressed("ui_down"):
		offset.y+=111
