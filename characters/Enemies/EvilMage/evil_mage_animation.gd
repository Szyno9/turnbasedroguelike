extends AnimationTree

var is_moving:bool
var direction_facing
enum DIRECTION_FACING{LEFT, RIGHT, UP, DOWN}

func _ready():
	get_parent().connect("character_damaged", Callable(self, "_on_character_damaged"))
	get_parent().connect("character_died", Callable(self, "_on_character_death"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	is_moving = get_parent().is_moving
	direction_facing = get_parent().direction_facing
	set("parameters/conditions/is_moving", is_moving)
	set("parameters/conditions/is_not_moving", !is_moving)
	match (direction_facing):
		Vector2i.LEFT:
			get_parent().scale.x = -1
		Vector2i.RIGHT:
			get_parent().scale.x = 1

func _on_character_damaged():
	get("parameters/playback").travel("hit")

func _on_character_death():
	get("parameters/playback").travel("death")
