extends Panel
@onready var continue_button = $HBoxContainer/VBoxContainer/ContinueButton as Button
@onready var main_menu_button = $HBoxContainer/VBoxContainer/MainMenuButton as Button
@onready var MAIN_MENU = preload("res://systems/user_inteface/main_menu.tscn")

func _ready():
	continue_button.button_down.connect(on_continue_down)
	main_menu_button.button_down.connect(on_main_menu_down)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and get_tree().paused == false:
		pause()
	elif event.is_action_pressed("ui_cancel") and get_tree().paused == true:
		resume()
		
func pause():
	get_tree().paused = true
	visible = true

func resume():
	get_tree().paused = false
	visible = false

func on_continue_down():
	resume()

func on_main_menu_down():
	get_tree().paused = false
	GlobalDataBus.change_to_scene("res://systems/user_inteface/main_menu.tscn")
