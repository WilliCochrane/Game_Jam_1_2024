extends weapon_type
class_name pistol


func _ready():
	full_auto = false
	bullet_type = "small"
	damage_range = Vector2(5,7)
	fire_rate_range = Vector2(3,5)
	mana_cost_range = Vector2(3,4)
	crit_chance_range = Vector2(10,20)
	bullet_size_range = Vector2(.75,.75)
	bullet_speed_range = Vector2(8,9)
	bullet_spread_range = Vector2(4,6)


func Update(_delta):
	anim_player.play("pistol")
