extends weapon_type
class_name MiniGun


func _ready():
	full_auto = true
	bullet_type = "small"
	damage_range = Vector2(1,2)
	fire_rate_range = Vector2(12,17)
	mana_cost_range = Vector2(.5,1)
	crit_chance_range = Vector2(10,20)
	bullet_size_range = Vector2(.75,.75)
	bullet_speed_range = Vector2(8,9)
	bullet_spread_range = Vector2(6,10)


func Update(_delta):
	anim_player.play("MiniGun")
