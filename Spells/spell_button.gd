extends Button

@export var spell_resource:Spell

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_properties(spell_resource1:Spell):
	text=spell_resource1.name
	spell_resource=spell_resource1
