extends AnimationTree

var is_moving:bool
var direction_facing
enum DIRECTION_FACING{LEFT, RIGHT, UP, DOWN}

func _ready():
	get_parent().connect("character_damaged", Callable(self, "_on_character_damaged"))
	GlobalDataBus.connect("player_died", Callable(self, "_on_character_death"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	
	is_moving = get_parent().is_moving
	direction_facing = get_parent().direction_facing
	set("parameters/conditions/is_moving", is_moving)
	set("parameters/Walk/conditions/is_moving", !is_moving)
	set("parameters/Idle/conditions/is_moving", is_moving)
	match (direction_facing):
		Vector2i.LEFT:
			set("parameters/Walk/conditions/side", true)
			set("parameters/Walk/conditions/front", false)
			set("parameters/Walk/conditions/back", false)
			
			set("parameters/Idle/conditions/side", true)
			set("parameters/Idle/conditions/front", false)
			set("parameters/Idle/conditions/back", false)
			get_parent().scale.x = 1
		Vector2i.RIGHT:
			set("parameters/Walk/conditions/side", true)
			set("parameters/Walk/conditions/front", false)
			set("parameters/Walk/conditions/back", false)
			
			set("parameters/Idle/conditions/side", true)
			set("parameters/Idle/conditions/front", false)
			set("parameters/Idle/conditions/back", false)
			get_parent().scale.x = -1
		Vector2i.UP:
			set("parameters/Walk/conditions/side", false)
			set("parameters/Walk/conditions/front", false)
			set("parameters/Walk/conditions/back", true)
			
			set("parameters/Idle/conditions/side", false)
			set("parameters/Idle/conditions/front", false)
			set("parameters/Idle/conditions/back", true)
		Vector2i.DOWN:
			set("parameters/Walk/conditions/side", false)
			set("parameters/Walk/conditions/front", true)
			set("parameters/Walk/conditions/back", false)
			
			set("parameters/Idle/conditions/side", false)
			set("parameters/Idle/conditions/front", true)
			set("parameters/Idle/conditions/back", false)

func _on_character_damaged():
	get("parameters/playback").travel("hit")

func _on_character_death():
	get("parameters/playback").travel("death")
