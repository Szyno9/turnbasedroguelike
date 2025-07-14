extends Panel
@onready var main_menu_button = $HBoxContainer/VBoxContainer/MainMenuButton as Button
@onready var MAIN_MENU = preload("res://systems/user_inteface/main_menu.tscn")
@onready var exit_button = $HBoxContainer/VBoxContainer/ExitButton
func _ready():
	GlobalDataBus.player_died.connect(_show_game_over_screen)
	exit_button.button_down.connect(on_exit_down)
	main_menu_button.button_down.connect(on_main_menu_down)
		
func on_exit_down():
	get_tree().quit()

func on_main_menu_down():
	GlobalDataBus.change_to_scene("res://systems/user_inteface/main_menu.tscn")

func _show_game_over_screen():
	await get_tree().create_timer(5).timeout
	visible = true
