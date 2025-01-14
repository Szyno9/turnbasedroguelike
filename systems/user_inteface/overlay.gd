extends TileMapLayer

@onready var Player_Character
var current_overlay:Array[Vector2i]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if Player_Character==null:
		Player_Character = %Player_Character
		Player_Character.connect("spell_casted", Callable(self, "_on_spell_casted"))
	clear()
	if Player_Character.next_attack == null:
		current_overlay = []
	for cell in current_overlay:
		set_cell(cell,0,Vector2i(0,0))
	set_cell(local_to_map(get_global_mouse_position()),0,Vector2i(1,0))
	

func get_range_circural(spell:Spell):
	const DIRECTIONS = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	var center = local_to_map(Player_Character.global_position)
	#var cell_array: Array =[]
	var cell_stack: Array = [center]
	var max_distance = spell.spell_range
	while not cell_stack.is_empty():
		var current = cell_stack.pop_back()
		if current in current_overlay:
			continue
		#if (center-current).abs().x + (center-current).abs().y>max_distance: #for amount of cells distance
			#continue
		if center.distance_to(current) > max_distance:
			continue
		current_overlay.append(current)
		
		for direction in DIRECTIONS:
			var cell: Vector2i = current + direction
			if cell in current_overlay:
				continue
			cell_stack.append(cell)

func _on_spells_ui_child_entered_tree(node):
	node.connect("pressed", Callable(self, "_spell_button_pressed").bind(node))

func _spell_button_pressed(spell_button:SpellButton):
	current_overlay = []
	var spell = Player_Character.spell_book.get_indexed_spell((spell_button.spell_index))
	match(spell.range_type):
		GlobalEnums.RANGE_TYPE.CIRCURAL:
			get_range_circural(spell)
	

func _on_spell_casted():
	current_overlay = []
