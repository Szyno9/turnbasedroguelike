extends Node2D

func _init():
	
	#var new_level_scene:LevelMap = 
	GlobalLevelMap.new_level()
	#var new_level_scene = new_level_res.instantiate()
	#add_child(new_level_scene)
	#new_level_scene.initialize()

func next_level():
	GlobalLevelMap.next_level()
