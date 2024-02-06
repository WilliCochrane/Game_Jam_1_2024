extends weapon_type
class_name FlameThrower


func _ready():
	full_auto = true
	flamethrow = true
	bullet_type = "Gradient"
	damage_range = Vector2(.5,1)
	fire_rate_range = Vector2(40,60)
	mana_cost_range = Vector2(.1,.1)
	crit_chance_range = Vector2(5,10)
	bullet_size_range = Vector2(.5,.5)
	bullet_speed_range = Vector2(2,2.5)
	bullet_spread_range = Vector2(3,5)


func Update(_delta):
	anim_player.play("FlameThrower")
