extends EnemyBase

const SPEED = 10.0

func _ready():
	super()
	spell_book.add_spell(load("res://Spells/slash/slash.tres"))
	#spell_book.add_spell(load("res://Spells/heal/heal.tres"))
	TurnQueue.global_tick.connect("timeout", Callable(self, "patrol"))
func _process(_delta):
	pass
func _physics_process(delta):
	super(delta)
	move_path()
	if TurnQueue.turn_mode and TurnQueue.active_char == self:
		if not is_moving and not ai_processing:
			turn_ai()
	
func die():
	var content = load("res://map_elements/SpellUpgrade/spell_upgrade.tscn")
	var upgrade = content.instantiate()
	upgrade.global_position = get_global_position()
	call_deferred("add_sibling",upgrade)
	super()
