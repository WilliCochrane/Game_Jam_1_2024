extends Node
class_name weapon_type
signal Transitioned

@export var anim_player : AnimationPlayer

var first_update : bool = true

var full_auto : bool
var flamethrow : bool = false
var bullet_type : String

var damage_range : Vector2
var fire_rate_range : Vector2
var mana_cost_range : Vector2
var crit_chance_range : Vector2
var bullet_size_range : Vector2
var bullet_speed_range : Vector2
var bullet_spread_range : Vector2

var damage : float
var fire_rate : float
var mana_cost : float
var crit_chance : float
var bullet_size : float
var bullet_speed : float
var bullet_spread : float

func Enter():
	pass

func Exit():
	pass

func Update(_delta: float):
	pass

func Physics_Update(_delta: float):
	if first_update == true:
		damage = randf_range(damage_range.x,damage_range.y)
		fire_rate = randf_range(fire_rate_range.x,fire_rate_range.y)
		mana_cost = randf_range(mana_cost_range.x,mana_cost_range.y)
		crit_chance = randf_range(crit_chance_range.x,crit_chance_range.y)
		bullet_size = randf_range(bullet_size_range.x,bullet_size_range.y)
		bullet_speed = randf_range(bullet_speed_range.x,bullet_speed_range.y)
		bullet_spread = randf_range(bullet_spread_range.x,bullet_spread_range.y)
		print(damage)
		first_update = false
