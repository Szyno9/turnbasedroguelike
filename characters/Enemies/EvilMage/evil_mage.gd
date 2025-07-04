extends EnemyBase

const SPEED = 10.0

func _ready():
	super()
	spell_book.add_spell(load("res://Spells/missle/missle.tres"))
	spell_book.add_spell(load("res://Spells/missle/missle.tres"))
	#spell_book.add_spell(load("res://Spells/heal/heal.tres"))
	TurnQueueGlobal.global_tick.connect("timeout", Callable(self, "patrol"))
func _process(_delta):
	pass
func _physics_process(delta):
	super(delta)
	move_path()
	if TurnQueueGlobal.turn_mode and TurnQueueGlobal.active_char == self:
		if not is_moving and not ai_processing:
			turn_ai()
	
func die():
	var content = load("res://rewards/SpellUpgrade/spell_upgrade.tscn")
	var upgrade = content.instantiate()
	upgrade.global_position = get_global_position()
	call_deferred("add_sibling",upgrade)
	super()
