extends AnimationTree

var is_moving:bool
var direction_facing
enum DIRECTION_FACING{LEFT, RIGHT, UP, DOWN}

func _ready():
	get_parent().connect("character_damaged", Callable(self, "_on_character_damaged"))
	get_parent().connect("character_died", Callable(self, "_on_character_death"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	direction_facing = get_parent().direction_facing
	match (direction_facing):
		Vector2i.LEFT:
			get_parent().scale.x = -1
		Vector2i.RIGHT:
			get_parent().scale.x = 1

func _on_character_damaged():
	print("jump")
	get("parameters/playback").travel("Jump")

func _on_character_death():
	print("end")
	get("parameters/playback").travel("end")
