extends Node

class_name GlobalBus

var current_scene_name

# Called when the node enters the scene tree for the first time.
func _ready():
	current_scene_name = get_tree().get_current_scene().name



# Scene transition managment
func change_to_scene(scene_path:String):
	current_scene_name = scene_path.get_file().get_basename()
	var current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	current_scene.queue_free()
	
	var new_scene = load(scene_path).instantiate()
	get_tree().get_root().call_deferred("add_child", new_scene) 
	get_tree().call_deferred("set_current_scene", new_scene)
