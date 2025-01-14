extends Resource

class_name Spell

#@export_group("Spell Characteristics") TODO
@export var name:String
@export var icon:Texture
#@export var sprite:Resource
@export var damage: int
@export var basic_cooldown:int
@export var cooldown: int
@export var spell_range:int
@export var range_type:GlobalEnums.RANGE_TYPE
@export var type:GlobalEnums.SPELL_TYPE
#@export var description: String
@export var action_cost: int
@export var spell_scene:PackedScene
