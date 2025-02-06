extends Interactable
@onready var Sprite = $Sprite2D
var amplitude := 1.0
var frequency := 2.0
var time = 0
@onready var default_pos = Sprite.get_position()

func _physics_process(delta):
	time += delta * frequency
	Sprite.set_position(default_pos + Vector2(0, sin(time) * amplitude))

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			GlobalDataBus.world_interaction.emit(self)

func on_interaction():
	queue_free()
