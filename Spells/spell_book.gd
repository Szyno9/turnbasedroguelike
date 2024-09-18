extends Node

var spell_array:Array
# Called when the node enters the scene tree for the first time.
func _ready():
	spell_array.append(load("res://Spells/missle/missle.tres"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func add_spell(spell_path:String):
	spell_array.append(load(spell_path))
