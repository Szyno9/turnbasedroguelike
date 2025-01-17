extends CanvasLayer

@onready var start_button = $HBoxContainer/VBoxContainer/StartButton as Button
@onready var exit_button = $HBoxContainer/VBoxContainer/ExitButton as Button
@onready var main = preload("res://main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	start_button.button_down.connect(on_start_down)
	exit_button.button_down.connect(on_exit_down)


func on_start_down():
	GlobalDataBus.change_to_scene("res://main.tscn")
	#get_tree().change_scene_to_packed(main)
func on_exit_down():
	get_tree().quit()
