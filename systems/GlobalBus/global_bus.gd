extends Node

class_name GlobalBus
var spell_interface = load("res://rewards/SpellUpgrade/spell_upgrade.tscn")
var spell_group_resource: ResourceGroup = load("res://Spells/all_spells.tres")
var enemies_resource: ResourceGroup = load("res://characters/Enemies/all_enemies.tres")
var reward_group_resource: ResourceGroup = load("res://rewards/all_rewards.tres")
var enemy_groups_resource: ResourceGroup = load("res://map_elements/monster_groups/all_enemy_groups.tres")
var all_spells:Array = spell_group_resource.load_all()
var all_enemies:Array = enemies_resource.load_all()
var all_rewards:Array = reward_group_resource.load_all()
var all_enemy_groups:Array = enemy_groups_resource.load_all()

var player_character: CharacterBase
var astar_grid: AStar2D
var elements=[]

var current_level:int = 0

var current_scene_name
signal world_interaction(element:Interactable)
signal open_spell_interface(spell_book:SpellBook)
signal spell_book_modified
signal level_changed
signal set_spawn_point(spawn_point:Vector2i)
signal move_to_next_level
# Called when the node enters the scene tree for the first time.
func _ready():
	current_scene_name = get_tree().get_current_scene().name

# Scene transition managment
func change_to_scene(scene_path:String):
	current_scene_name = scene_path.get_file().get_basename()
	var current_scene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1)
	current_scene.queue_free()
	
	var new_scene = load(scene_path).instantiate()
	get_tree().get_root().call_deferred("add_child", new_scene) 
	get_tree().call_deferred("set_current_scene", new_scene)

func progress_to_next_level():
	current_level += 1
