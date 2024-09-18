extends Button

@export var spell_scene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_properties(name:String, spell_scene1:PackedScene):
	text=name
	spell_scene=spell_scene1
