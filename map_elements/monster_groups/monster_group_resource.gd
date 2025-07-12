extends Resource

class_name MonsterGroup
@export var name: String
@export var _content: Array[PackedScene]
@export var map_levels: Array[int]


func get_monsters() -> Array[PackedScene]:
	return _content
#var start: int
#var current: int
#var end: int
#var increment: int
#
#func _init(start, stop, increment):
	#self.start = start
	#self.current = start
	#self.end = stop
	#self.increment = increment
#
#func _iter_init(arg):
	#current = start
	#return should_continue()
#
#func _iter_next(arg):
	#current += increment
	#return should_continue()
#
#func _iter_get(arg):
	#return current
#
#func should_continue():
	#return (current < end)
